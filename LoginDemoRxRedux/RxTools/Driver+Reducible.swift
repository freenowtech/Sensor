//
//  Driver+Reducible.swift
//  mytaxiDriver
//
//  Created by David Cortés Fulla on 3/10/18.
//  Copyright © 2018 Intelligent Apps GmbH. All rights reserved.
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

extension ReducibleStateWithEffects {

    private typealias Feedback<S, M> = (Driver<S>) -> Signal<M>

    static func outputStates(initialState: Self, inputEvents: Signal<Event>, context: Context) -> Driver<Self> {

        let inputFeedback: Feedback<StateAndEffects<Self>, Event> = { _ in return Signal<Event>.merge(inputEvents) }
        let reactFeedback: Feedback<StateAndEffects<Self>, Event> =
            react(requests: { (stateAndEffects: StateAndEffects<Self>) -> Set<StateAndEffect<Self>> in
                let mappedStates = stateAndEffects.effects.map { (effect: Effect) -> StateAndEffect<Self> in
                    return StateAndEffect<Self>(state: stateAndEffects.state, effect: effect)
                }
                return Set(mappedStates)
            }, effects: { (stateAndEffect: StateAndEffect<Self>) -> Signal<Event> in
                return stateAndEffect.effect.trigger(context: context)
            })
        let reduce: (StateAndEffects<Self>, Event) -> StateAndEffects<Self> = { state, event in
            let reduced = state.state.reduce(event: event)
            return StateAndEffects<Self>(state: reduced.state, effects: reduced.effects)
        }
        let initial = StateAndEffects<Self>(state: initialState, effects: [])

        return Driver.system(initialState: initial, reduce: reduce, feedback: inputFeedback, reactFeedback)
            .map { $0.state }
    }

}
