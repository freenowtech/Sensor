//
//  Driver+Reducible.swift
//  Sensor
//
//  Created by David Cortés Fulla on 3/10/18.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

public protocol SensorFeature {
    associatedtype State
    associatedtype Event
    associatedtype Effect: Hashable

    static var reducer: Reducer<State, Effect, Event> { get }

    var effectsImplementation: EffectsImplementation<Effect, Event> { get }
}

// Re-export of the public SensorFeatureInternal methods
extension SensorFeature {
    /// Creates the state machine feedback loop.
    ///
    /// - Parameters:
    ///   - initialState: The first state that the state machine will sequence.
    ///   - inputEvents: The externally generated events that drive the state machine.
    /// - Returns: An observable for the sequenced states of the state machine.
    public func outputStates(
        initialState: State,
        inputEvents: Signal<Event>
    ) -> Driver<State> {
        SensorFeatureInternal(self).outputStates(initialState: initialState, inputEvents: inputEvents)
    }

    /// Creates the state machine feedback loop and returns a set of observables that can be used on tests to assert the behaviour of the state machine.
    ///
    /// Use this method only in unit tests. You shouldn't use the `effects` and `events` signals for other purposes than testing the state machine.
    /// For production code, use `outputStates(initialState:inputEvents)`.
    ///
    /// - Parameters:
    ///   - initialState: The first state that the state machine will sequence.
    ///   - inputEvents: The externally generated events that drive the state machine.
    /// - Returns: Observables for the sequenced states, the received events and the triggered effects of the state machine.
    internal func testOutputs(
        initialState: State,
        inputEvents: Signal<Event>
    ) -> EventsStatesAndEffects<Event, State, Effect> {
        SensorFeatureInternal(self).testOutputs(initialState: initialState, inputEvents: inputEvents)
    }
}

/// A version of SensorFeature that has the reducer non-static. This helps us write the unit tests of Sensor.
/// This struct is extended with the implementation of the Sensor methods. SensorFeature reuses this implementation.
struct SensorFeatureInternal<State, Effect: Hashable, Event> {
    init(reducer: Reducer<State, Effect, Event>, effectsImplementation: EffectsImplementation<Effect, Event>) {
        self.reducer = reducer
        self.effectsImplementation = effectsImplementation
    }

    init<S: SensorFeature>(_ sensorFeature: S) where S.State == State, S.Effect == Effect, S.Event == Event {
        self.reducer = S.reducer
        self.effectsImplementation = sensorFeature.effectsImplementation
    }

    let reducer: Reducer<State, Effect, Event>
    let effectsImplementation: EffectsImplementation<Effect, Event>
}

// MARK: Triggerable Effect

public struct EffectsImplementation<Effect, Event> {

    public init(trigger: @escaping (Effect) -> Signal<Event>) {
        self.trigger = trigger
    }

    let trigger: (Effect) -> Signal<Event>

    public func callAsFunction(_ effect: Effect) -> Signal<Event> {
        trigger(effect)
    }
}

/// An EffectHandle identifies a triggered effect and can be used to cancel it.
public struct EffectHandle<Effect> {
    // The id allows us to have two different "instances" of the same effect
    // in the feedback loop.
    internal let id: UInt
    internal let effect: Effect

    internal init(_ id: UInt, _ effect: Effect) {
        self.id = id
        self.effect = effect
    }
}

extension EffectHandle: Equatable where Effect: Equatable {}
extension EffectHandle: Hashable where Effect: Hashable {}

// MARK: Reducible State With Effects

public struct Reducer<State, Effect: Hashable, Event> {

    public init(reduce: @escaping (State, Event) -> ValidEffectsDSL<State, Effect>) {
        self.reduce = reduce
    }

    let reduce: (State, Event) -> ValidEffectsDSL<State, Effect>

    public func callAsFunction(_ currentState: State, _ event: Event) -> ValidEffectsDSL<State, Effect> {
        reduce(currentState, event)
    }
}

//
// MARK: Private structs required to match RxFeedback types
//

private struct StateAndEffects<State, Effect> where Effect: Hashable {
    let state: State
    let effects: Set<EffectHandle<Effect>>
    let nextEffectId: UInt
}

internal struct EventsStatesAndEffects<Event, State, Effect> {
    let events: Signal<Event>
    let states: Driver<State>
    let ongoingEffectsHandles: Signal<[EffectHandle<Effect>]>
    let triggeredEffectsHandles: Signal<[EffectHandle<Effect>]>

    var ongoingEffects: Signal<[Effect]> {
        return ongoingEffectsHandles.map { handles in handles.map { $0.effect } }
    }

    var triggeredEffects: Signal<[Effect]> {
        return triggeredEffectsHandles.map { handles in handles.map { $0.effect } }
    }

    init(events: Signal<Event>, states: Driver<State>, ongoingEffectsHandles: Signal<[EffectHandle<Effect>]>, triggeredEffectsHandles: Signal<[EffectHandle<Effect>]>) {
        self.events = events
        self.states = states
        self.ongoingEffectsHandles = ongoingEffectsHandles
        self.triggeredEffectsHandles = triggeredEffectsHandles
    }
}

extension SensorFeatureInternal {

    private typealias Feedback<S, M> = (Driver<S>) -> Signal<M>

    /// Creates the state machine feedback loop.
    ///
    /// - Parameters:
    ///   - initialState: The first state that the state machine will sequence.
    ///   - inputEvents: The externally generated events that drive the state machine.
    /// - Returns: An observable for the sequenced states of the state machine.
    public func outputStates(
        initialState: State,
        inputEvents: Signal<Event>
    ) -> Driver<State> {
        return testOutputs(initialState: initialState, inputEvents: inputEvents).states
    }

    /// Creates the state machine feedback loop and returns a set of observables that can be used on tests to assert the behaviour of the state machine.
    ///
    /// Use this method only in unit tests. You shouldn't use the `effects` and `events` signals for other purposes than testing the state machine.
    /// For production code, use `outputStates(initialState:inputEvents)`.
    ///
    /// - Parameters:
    ///   - initialState: The first state that the state machine will sequence.
    ///   - inputEvents: The externally generated events that drive the state machine.
    /// - Returns: Observables for the sequenced states, the received events and the triggered effects of the state machine.
    internal func testOutputs(
        initialState: State,
        inputEvents: Signal<Event>
    ) -> EventsStatesAndEffects<Event, State, Effect> {

        let internalEventsStatsAndEffects = privateTestOutputs(initialState: initialState,
                                                               inputEvents: inputEvents)
        return EventsStatesAndEffects(
            events: internalEventsStatsAndEffects.events,
            states: internalEventsStatsAndEffects.states,
            ongoingEffectsHandles: internalEventsStatsAndEffects.ongoingEffectsHandles,
            triggeredEffectsHandles: internalEventsStatsAndEffects.triggeredEffectsHandles.filter { $0.count > 0 }
        )
    }

    internal func privateTestOutputs(
        initialState: State,
        inputEvents: Signal<Event>
    ) -> EventsStatesAndEffects<Event, State, Effect> {

        let (events, stateAndEffects) = outputs(initialState: initialState,
                                                inputEvents: inputEvents)
        let ongoingEffectsHandles = stateAndEffects.map { $0.effects.sorted(by: { $0.id < $1.id }) }.asSignal(onErrorSignalWith: .empty())
        let triggeredEffectsHandles = ongoingEffectsHandles.pairwise().map { previous, current in
            current.removingElements(from: previous)
        }
        return EventsStatesAndEffects(
            events: events,
            states: stateAndEffects.map { $0.state },
            ongoingEffectsHandles: ongoingEffectsHandles,
            triggeredEffectsHandles: triggeredEffectsHandles
        )
    }

    /// Creates the state machine feedback loop and returns a set of observables that can be used on tests to assert the behaviour of the state machine.
    ///
    /// This method cannot be used directly by code outside this extension. To better communicate your intent, use either
    /// `outputStates(initialState:inputEvents)` for production code
    /// or `testOutputs(initialState:inputEvents)` for unit tests.
    ///
    /// - Parameters:
    ///   - initialState: The first state that the state machine will sequence.
    ///   - inputEvents: The externally generated events that drive the state machine.
    /// - Returns: Observables for the sequenced states, the received events and the triggered effects of the state machine.
    private func outputs(
        initialState: State,
        inputEvents: Signal<Event>
    ) -> (events: Signal<Event>, stateAndEffects: Driver<StateAndEffects<State, Effect>>) {

        let eventsRelay = PublishSubject<Event>()
        let inputFeedback: Feedback<StateAndEffects<State, Effect>, Event> = { _ in
            inputEvents
        }
        let reactFeedback: Feedback<StateAndEffects<State, Effect>, Event> =
            react(requests: { (stateAndEffects: StateAndEffects<State, Effect>) -> Set<EffectHandle<Effect>> in
                stateAndEffects.effects
            }, effects: { [effectsImplementation] (effectHandle: EffectHandle<Effect>) -> Signal<Event> in
                effectsImplementation(effectHandle.effect)
            })
        let reduce: (StateAndEffects<State, Effect>, Event) -> StateAndEffects<State, Effect> = { [reducer] previousState, event in
            eventsRelay.onNext(event)
            let reduced = reducer(previousState.state, event)
            var nextEffectId = previousState.nextEffectId
            let (newState, newEffectSet) = reduced.commands.apply(to: previousState.effects, nextEffectId: &nextEffectId)
            return StateAndEffects<State, Effect>(
                state: newState ?? previousState.state,
                effects: newEffectSet,
                nextEffectId: nextEffectId
            )
        }
        let initial = StateAndEffects<State, Effect>(state: initialState, effects: [], nextEffectId: 0)

        let stateAndEffects: Driver<StateAndEffects<State, Effect>> = Driver.system(initialState: initial, reduce: reduce, feedback: inputFeedback, reactFeedback)

        return (
            events: eventsRelay.asSignal(onErrorSignalWith: .empty()),
            stateAndEffects: stateAndEffects
        )
    }
}
