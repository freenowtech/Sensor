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

// MARK: Reducible State

public protocol ReducibleState: Equatable {
    associatedtype Event
    func reduce(event: Event) -> Self
}

extension ReducibleState {

    static func outputStates(initialState: Self, inputEvents: Signal<Event>) -> Driver<Self> {
        return inputEvents
            .scan(initialState, accumulator: { (previousState: Self, event: Self.Event) -> Self in
                return previousState.reduce(event: event)
            })
            .asDriver(onErrorJustReturn: initialState)
            .startWith(initialState)
            .distinctUntilChanged()
    }

}

// MARK: Triggerable Effect

public protocol TriggerableEffect: Hashable {
    associatedtype Context
    associatedtype Event

    func trigger(context: Context) -> Signal<Event>
}

// MARK: Reducible State With Effects

public protocol ReducibleStateWithEffects: Hashable {
    associatedtype Effect: TriggerableEffect
    typealias Event = Effect.Event
    typealias Context = Effect.Context

    func reduce(event: Event) -> (state: Self, effects: Set<Effect>)
}

//
// MARK: Private structs required to match RxFeedback types
//

private struct StateAndEffects<State: ReducibleStateWithEffects>: Hashable {
    let state: State
    let effects: Set<State.Effect>
}

private struct StateAndEffect<State: ReducibleStateWithEffects>: Hashable {
    let state: State
    let effect: State.Effect
}

struct EventsStatesAndEffects<Event, State, Effect: Hashable> {
    let events: Signal<Event>
    let states: Driver<State>
    let effects: Signal<Set<Effect>>
}

extension ReducibleStateWithEffects {

    private typealias Feedback<S, M> = (Driver<S>) -> Signal<M>

    /// Creates the state machine feedback loop.
    ///
    /// - Parameters:
    ///   - initialState: The first state that the state machine will sequence.
    ///   - inputEvents: The externally generated events that drive the state machine.
    ///   - context: The context is passed to the effects and can be used to inject external dependencies to them.
    /// - Returns: An observable for the sequenced states of the state machine.
    public static func outputStates(initialState: Self, inputEvents: Signal<Event>, context: Context) -> Driver<Self> {
        return outputs(initialState: initialState, inputEvents: inputEvents, context: context).states
    }

    /// Creates the state machine feedback loop and returns a set of observables that can be used on tests to assert the behaviour of the state machine.
    ///
    /// Use this method only in unit tests. You shouldn't use the `effects` and `events` signals for other purposes than testing the state machine.
    /// For production code, use `outputStates(initialState:inputEvents:context)`.
    ///
    /// - Parameters:
    ///   - initialState: The first state that the state machine will sequence.
    ///   - inputEvents: The externally generated events that drive the state machine.
    ///   - context: The context is passed to the effects and can be used to inject external dependencies to them.
    /// - Returns: Observables for the sequenced states, the received events and the triggered effects of the state machine.
    internal static func testOutputs(initialState: Self, inputEvents: Signal<Event>, context: Context) -> EventsStatesAndEffects<Event, Self, Effect> {
        return outputs(initialState: initialState, inputEvents: inputEvents, context: context)
    }

    /// Creates the state machine feedback loop and returns a set of observables that can be used on tests to assert the behaviour of the state machine.
    ///
    /// This method cannot be used directly by code outside this extension. To better communicate your intent, use either
    /// `outputStates(initialState:inputEvents:context)` for production code
    /// or `testOutputs(initialState:inputEvents:context)` for unit tests.
    ///
    /// - Parameters:
    ///   - initialState: The first state that the state machine will sequence.
    ///   - inputEvents: The externally generated events that drive the state machine.
    ///   - context: The context is passed to the effects and can be used to inject external dependencies to them.
    /// - Returns: Observables for the sequenced states, the received events and the triggered effects of the state machine.
    private static func outputs(initialState: Self, inputEvents: Signal<Event>, context: Context) -> EventsStatesAndEffects<Event, Self, Effect> {
        let eventsRelay = PublishSubject<Signal<Event>>()
        let inputFeedback: Feedback<StateAndEffects<Self>, Event> = { _ in
            let events = Signal<Event>.merge(inputEvents)
            eventsRelay.onNext(events)
            // `events` shares side effects because its a signal, thus it's safe to return it while also publish it to the relay.
            return events
        }
        let reactFeedback: Feedback<StateAndEffects<Self>, Event> =
            react(requests: { (stateAndEffects: StateAndEffects<Self>) -> Set<StateAndEffect<Self>> in
                let mappedStates = stateAndEffects.effects.map { (effect: Effect) -> StateAndEffect<Self> in
                    return StateAndEffect<Self>(state: stateAndEffects.state, effect: effect)
                }
                return Set(mappedStates)
            }, effects: { (stateAndEffect: StateAndEffect<Self>) -> Signal<Event> in
                let events = stateAndEffect.effect.trigger(context: context)
                // `events` shares side effects because its a signal, thus it's safe to return it while also publish it to the relay.
                eventsRelay.onNext(events)
                return events
            })
        let reduce: (StateAndEffects<Self>, Event) -> StateAndEffects<Self> = { state, event in
            let reduced = state.state.reduce(event: event)
            return StateAndEffects<Self>(state: reduced.state, effects: reduced.effects)
        }
        let initial = StateAndEffects<Self>(state: initialState, effects: [])

        let stateAndEffects: Driver<StateAndEffects<Self>> = Driver.system(initialState: initial, reduce: reduce, feedback: inputFeedback, reactFeedback)

        return EventsStatesAndEffects(
            events: eventsRelay.flatMap({ $0 }).asSignal(onErrorSignalWith: Signal.never()),
            states: stateAndEffects.map { $0.state },
            effects: stateAndEffects.map { $0.effects }.asSignal(onErrorSignalWith: Signal.never())
        )
    }
}
