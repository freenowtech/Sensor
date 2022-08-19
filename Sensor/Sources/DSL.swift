//
//  EffectsCommands.swift
//  Sensor
//
//  Created by Ferran Pujol Camins on 28/08/2020.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.

public func then<State, Effect>() -> EffectsDSLMissingNextState1<State, Effect> {
    .init(commands: .init())
}

public func stayOnCurrentState<State, Effect>() -> ValidEffectsDSL<State, Effect> {
    .init(commands: .init())
}

public struct EffectsDSLMissingNextState1<State, Effect: Hashable> {
    public func cancelAllEffects() -> EffectsDSLMissingNextState1 {
        .init(commands: commands.cancelAllEffects())
    }

    public func cancel(_ canceledEffects: [EffectHandle<Effect>]) -> EffectsDSLMissingNextState1 {
        .init(commands: commands.cancel(canceledEffects))
    }

    public func cancel(_ canceledEffects: EffectHandle<Effect>...) -> EffectsDSLMissingNextState1 {
        cancel(canceledEffects)
    }

    public func cancel(_ canceledEffects: [EffectHandle<Effect>?]) -> EffectsDSLMissingNextState1 {
        .init(commands: commands.cancel(canceledEffects.compactMap { $0 }))
    }

    public func cancel(_ canceledEffects: EffectHandle<Effect>?...) -> EffectsDSLMissingNextState1 {
        cancel(canceledEffects)
    }

    public func trigger(_ newEffects: [Effect]) -> EffectsDSLMissingNextState2<State, Effect> {
        .init(commands: commands.trigger(newEffects))
    }

    public func trigger(_ newEffects: Effect...) -> EffectsDSLMissingNextState2<State, Effect> {
        trigger(newEffects)
    }

    public func trigger(_ newEffect: Effect, _ continuation: @escaping (EffectHandle<Effect>) -> EffectsDSLMissingNextState2<State, Effect>) -> EffectsDSLMissingNextState2<State, Effect> {
        trigger(newEffect, Function(continuation))
    }

    public func trigger(_ newEffect: Effect, _ continuation: Function<EffectHandle<Effect>, EffectsDSLMissingNextState2<State, Effect>>) -> EffectsDSLMissingNextState2<State, Effect> {
        .init(commands: commands.trigger(newEffect, continuation.map(\.commands)))
    }

    public func trigger(_ newEffect: Effect, _ continuation: @escaping (EffectHandle<Effect>) -> ValidEffectsDSL<State, Effect>) -> ValidEffectsDSL<State, Effect> {
        trigger(newEffect, Function(continuation))
    }

    public func trigger(_ newEffect: Effect, _ continuation: Function<EffectHandle<Effect>, ValidEffectsDSL<State, Effect>>) -> ValidEffectsDSL<State, Effect> {
        .init(commands: commands.trigger(newEffect, continuation.map(\.commands)))
    }

    public func goTo(_ state: State) -> ValidEffectsDSL<State, Effect> {
        .init(commands: commands.setState(state))
    }

    public func stayOnCurrentState() -> ValidEffectsDSL<State, Effect> {
        .init(commands: commands)
    }

    let commands: Commands<State, Effect>
}

public struct EffectsDSLMissingNextState2<State, Effect: Hashable> {

    public func trigger(_ newEffects: [Effect]) -> EffectsDSLMissingNextState2 {
        .init(commands: commands.trigger(newEffects))
    }

    public func trigger(_ newEffects: Effect...) -> EffectsDSLMissingNextState2 {
        trigger(newEffects)
    }

    public func trigger(_ newEffect: Effect, _ continuation: @escaping (EffectHandle<Effect>) -> EffectsDSLMissingNextState2) -> EffectsDSLMissingNextState2 {
        trigger(newEffect, Function(continuation))
    }

    public func trigger(_ newEffect: Effect, _ continuation: Function<EffectHandle<Effect>, EffectsDSLMissingNextState2>) -> EffectsDSLMissingNextState2 {
        .init(commands: commands.trigger(newEffect, continuation.map(\.commands)))
    }

    public func trigger(_ newEffect: Effect, _ continuation: @escaping (EffectHandle<Effect>) -> ValidEffectsDSL<State, Effect>) -> ValidEffectsDSL<State, Effect> {
        trigger(newEffect, Function(continuation))
    }

    public func trigger(_ newEffect: Effect, _ continuation: Function<EffectHandle<Effect>, ValidEffectsDSL<State, Effect>>) -> ValidEffectsDSL<State, Effect> {
        .init(commands: commands.trigger(newEffect, continuation.map(\.commands)))
    }

    public func goTo(_ state: State) -> ValidEffectsDSL<State, Effect> {
        .init(commands: commands.setState(state))
    }

    public func stayOnCurrentState() -> ValidEffectsDSL<State, Effect> {
        .init(commands: commands)
    }

    let commands: Commands<State, Effect>
}

public struct ValidEffectsDSL<State, Effect: Hashable> {
    public func trigger(_ newEffect: Effect, _ continuation: @escaping (EffectHandle<Effect>) -> EffectsDSLMissingNextState2<State, Effect>) -> Self {
        trigger(newEffect, Function(continuation))
    }

    public func trigger(_ newEffect: Effect, _ continuation: Function<EffectHandle<Effect>, EffectsDSLMissingNextState2<State, Effect>>) -> Self {
        .init(commands: commands.trigger(newEffect, continuation.map(\.commands)))
    }

    let commands: Commands<State, Effect>
}

struct Commands<State, Effect: Hashable> {

    enum Command {
        case effectsDiff(EffectsDiff<Effect>)
        case continuation(effect: Effect, continuation: Function<EffectHandle<Effect>, Commands>)
    }

    init() {
        self.commands = []
        self.state = nil
    }

    init(_ commands: [Command], _ state: State?) {
        self.commands = commands
        self.state = state
    }

    func cancelAllEffects() -> Self {
        appending(.effectsDiff(.cancelAllEffects()))
    }

    func cancel(_ canceledEffects: [EffectHandle<Effect>]) -> Self {
        appending(.effectsDiff(.cancel(canceledEffects)))
    }

    func trigger(_ newEffects: [Effect]) -> Self {
        appending(.effectsDiff(.trigger(newEffects)))
    }

    func trigger(_ newEffect: Effect, _ continuation: Function<EffectHandle<Effect>, Self>) -> Self {
        appending(.continuation(effect: newEffect, continuation: continuation))
    }

    func setState(_ state: State) -> Self {
        Self(commands, state)
    }

    let commands: [Command]
    let state: State?

    private func appending(_ command: Command) -> Self {
        Self(commands + [command], state)
    }
}

public struct EffectsDiff<Effect: Hashable> {
    let shouldCancelAll: Bool
    let canceledEffects: Set<EffectHandle<Effect>>
    let newEffects: [Effect]

    func cancelAllEffects() -> Self {
        Self(shouldCancelAll: true, canceledEffects: canceledEffects, newEffects: newEffects)
    }

    func cancel(_ canceledEffects: [EffectHandle<Effect>]) -> Self {
        Self(
            shouldCancelAll: shouldCancelAll,
            canceledEffects: self.canceledEffects.union(canceledEffects),
            newEffects: newEffects
        )
    }

    func trigger(_ newEffects: [Effect]) -> Self {
        Self(
            shouldCancelAll: shouldCancelAll,
            canceledEffects: canceledEffects,
            newEffects: self.newEffects + newEffects
        )
    }

    static func cancelAllEffects() -> Self {
        Self.noop().cancelAllEffects()
    }

    static func cancel(_ canceledEffects: [EffectHandle<Effect>]) -> Self {
        Self.noop().cancel(canceledEffects)
    }

    static func trigger(_ newEffects: [Effect]) -> Self {
        Self.noop().trigger(newEffects)
    }

    static func noop() -> Self {
        Self(shouldCancelAll: false, canceledEffects: [], newEffects: [])
    }
}

public struct Function<I, O> {
    init(_ f: @escaping (I) -> O) {
        self.f = f
    }

    let f: (I) -> O

    func callAsFunction(_ i: I) -> O {
        f(i)
    }

    func map<T>(_ g: @escaping (O) -> T) -> Function<I, T> {
        Function<I, T>({ g(self.f($0)) })
    }
}

extension Commands {

    func apply(
        to ongoingEffects: Set<EffectHandle<Effect>>,
        nextEffectId: inout UInt
    ) -> (State?, Set<EffectHandle<Effect>>) {

        var ongoingEffects = ongoingEffects
        var newState: State? = state
        for command in commands {
            switch command {
            case let .effectsDiff(effectsDiff):
                ongoingEffects = effectsDiff.apply(to: ongoingEffects, nextEffectId: &nextEffectId)

            case let .continuation(effect: effect, continuation: continuation):
                let handle = EffectHandle(nextEffectId, effect)
                ongoingEffects.insert(handle)
                nextEffectId += 1
                let newStateFromContinuation: State?
                (newStateFromContinuation, ongoingEffects) = continuation(handle).apply(to: ongoingEffects, nextEffectId: &nextEffectId)
                newState = newState ?? newStateFromContinuation
            }
        }
        return (newState, ongoingEffects)
    }
}

extension EffectsDiff {
    func apply(
        to ongoingEffects: Set<EffectHandle<Effect>>,
        nextEffectId: inout UInt
    ) -> Set<EffectHandle<Effect>>{

        var ongoingEffects = ongoingEffects
        if shouldCancelAll {
            ongoingEffects.removeAll()
        } else {
            ongoingEffects.subtract(canceledEffects)
        }

        for newEffect in newEffects {
            ongoingEffects.insert(EffectHandle(nextEffectId, newEffect))
            nextEffectId += 1
        }
        return ongoingEffects
    }
}
