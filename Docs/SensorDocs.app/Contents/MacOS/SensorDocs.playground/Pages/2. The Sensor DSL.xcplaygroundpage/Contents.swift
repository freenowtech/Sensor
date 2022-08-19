// # 2. The Sensor DSL
//
// ## DSL Examples

// Here we give examples of how to use the Sensor DSL for the most common use cases.
import Foundation
import Sensor

enum Effect {
    case effect1
    case effect2
}

struct State {
    let value: Int
    let effectHandle1: EffectHandle<Effect>?
    let effectHandle2: EffectHandle<Effect>?
}

enum Event {
    case event1
    case event2
    case event3
    case event4
    case event5
    case event6
    case event7
    case event8
}


let reducer = Reducer<State, Effect, Event> { state, event in
    switch event {
// Trigger one effect and transition to a new state:
    case .event1:
        return then()
            .trigger(.effect1)
            .goTo(State(value: 1, effectHandle1: nil, effectHandle2: nil))
// Trigger several effects and transition to a new state:
    case .event2:
        return then()
            .trigger(.effect1, .effect2)
            .goTo(State(value: 2, effectHandle1: nil, effectHandle2: nil))
// Trigger one effect without changing the state:
    case .event3:
        return then()
            .trigger(.effect1)
            .stayOnCurrentState()
// Trigger an effect and save its handle, so we can cancel it later.
//
// The `trigger` method accepts a closure as second parameter. The code inside the closure
// can use the passed `handle` parameter, which is a reference to the effect triggered by the
// `trigger` method. This handle can be used to cancel the effect. In order to do so, we need to
// save it somewhere in our state.
//
// Inside the closure we can use the `then()` function and the Sensor DSL again to define the next state.
// To define the new state we now use the `handle`, so we can access it later.
    case .event4:
        return then()
            .trigger(.effect1) { handle in
                then()
                    .goTo(State(
                            value: 4,
                            effectHandle1: handle,
                            effectHandle2: nil
                    ))
            }
// Trigger several effect and save their handles, so we can cancel them later.
//
// If we need to save handles for several effects, we can just nest calls to `trigger` and use
// both handles in the inner-most closure.
    case .event5:
        return then()
            .trigger(.effect1) { handle1 in
                then()
                    .trigger(.effect2) { handle2 in
                        then()
                        .goTo(State(
                            value: 5,
                            effectHandle1: handle1,
                            effectHandle2: handle2
                        ))
                    }
            }
// Cancel a specific effect:
//
// Notice how we can pass an optional handle to the `cancel` method. Sensor will cancel the effect if the
// handle is not nil and will safely ignore nil values.
    case .event6:
        return then()
            .cancel(state.effectHandle1)
            .goTo(State(value: state.value, effectHandle1: nil, effectHandle2: nil))
// Cancel all ongoing effects:
    case .event7:
        return then()
            .cancelAllEffects()
            .goTo(State(value: state.value, effectHandle1: nil, effectHandle2: nil))
// Whenever you don't need to trigger any effect nor go to a new state, you can omit `then()` and just call `stayOnCurrentState()`.
// It's a shorthand for `then().goTo(state)`
    case .event8:
        return
            stayOnCurrentState()
    }
}

// ## Troubleshooting, common mistakes and pitfalls.
//
// ### Effect trigger order is not guaranteed
//
// The order in which effects of the same reducer case are triggered is not guaranteed.
// This means that when we trigger several effects we don't know in which order they will actually be triggered.
// and thus our code must not rely in any particular order.
// For example, if we have the following code it is possible that sometimes `effect2` is triggered before `effect1`.
// ```
// case .event:
//     return then()
//         .trigger(.effect1)
//         .trigger(.effect2)
//         .stayOnCurrentState()
// ```
// This is also true even if one effect depends on the handle of the other effect.
// In this situation `effect2` might sill be called before `effect1`.
// So, for example, we cannot use `effect2` to perform any work that depends on `effect1`
// being already triggered.
// ```
// case .event:
//     return then()
//         .trigger(.effect1) { handle in
//             then()
//                 .trigger(.effect2(handle))
//                 .stayOnCurrentState()
//         }
// ```
//
// #### Workaround 1: Use intermediate states
// One way to enforce the order of two effects is to trigger them at different reducer calls.
// To do so, we must add an intermediate state (I). Then, when we transition from state A to I, we
// can trigger the first effect. After, we transition from I to B and trigger the second effect.
//
// Let's see an example. Suppose that we want to trigger effects 1 and 2 as we transition from state1 to `state2`.
enum W1Effect {
    case effect1
    case effect2
}

enum W1State {
    case state1
    case state2
}

enum W1Event {
    case event1
}

// If we naively write our reducer like this, we don't have any guarantee that `effect1` will actually be
// triggered before `effect2`

let w1Reducer = Reducer<W1State, W1Effect, W1Event> { state, event in
    switch (state, event) {
    case (.state1, .event1):
        return then()
            .trigger(.effect1, .effect2)
            .goTo(.state2)
    default:
        return stayOnCurrentState()
    }
}

// We can add an intermediate state, event and effect to make the reducer execute two times, and trigger
// one effect each time. This will guarantee the order of the effects.

enum W1Effect2 {
    case effect1
    case effect2
    case goToState2
}

enum W1State2 {
    case state1
    case intermediateState
    case state2
}

enum W1Event2 {
    case event1
    case continueToState2
}

let w1Reducer2 = Reducer<W1State2, W1Effect2, W1Event2> { state, event in
    switch (state, event) {
    case (.state1, .event1):
        return then()
            .trigger(.effect1, .goToState2)
            .goTo(.intermediateState)
    case (.intermediateState, .continueToState2):
        return then()
            .trigger(.effect2)
            .goTo(.state2)
    default:
        return stayOnCurrentState()
    }
}

let w1EffectsImplementation2: EffectsImplementation<W1Effect2, W1Event2> =
    EffectsImplementation { effect in
        switch effect {
        case .effect1, .effect2:
            return .just(.event1) // Do whatever
        case .goToState2:
            return .just(.continueToState2)
        }
    }
//
// TODO: add a more detailed explanation.
//
// #### Workaround 2: Combine all effects into a single effect
// If your effects implementation looks like this:
enum W2Effect {
    case effect1
    case effect2
}
enum W2State {
    case state1
    case state2
}
enum W2Event {}
let w2EffectsImplementation: EffectsImplementation<W2Effect, W2Event> =
    EffectsImplementation { effect in
        switch effect {
        case .effect1:
            print("Print1")
            return .empty()
        case .effect2:
            print("Print2")
            return .empty()
        }
    }
// You can add an additional effect that sequentially executes the instructions of `effect1` and `effect2`.
// This way you can guarantee that the work of `effect1` is executed before the work of `effect2`.
enum W2Effect2 {
    case effect1
    case effect2
    case effect1Then2
}

let w2EffectsImplementation2: EffectsImplementation<W2Effect2, W2Event> =
    EffectsImplementation { effect in
        switch effect {
        case .effect1:
            print("Print1")
            return .empty()
        case .effect2:
            print("Print2")
            return .empty()
        case .effect1Then2:
            print("Print1")
            print("Print2")
            return .empty()
        }
    }
//
// TODO: add a more detailed example of this.
// ```
// ```
//
// ### Forgetting to add return before then()
//
// If you forget to add the return before the call to `then()`
// ```
// case .event:
//     then()
//         .trigger(.effect)
//         .stayOnCurrentState()
// ```
// You will get an error similar to this one
// ```
// error: missing return in a closure expected to return 'ValidEffectsDSL<State, Effect>'
// }
// ^
// ```
// To fix it just add `return` before the `then` call:
// ```
// case .event:
//     return then()
//         .trigger(.effect)
//         .stayOnCurrentState()
// ```
//
// ### Forgetting to call then() before other effect commands
//
// If you forget to call `then` before calling other effects commands
// ```
// case .event:
//     return trigger(.effect)
//         .stayOnCurrentState()
// ```
// You will get an error similar to this one
// ```
// error: use of unresolved identifier 'trigger'
// return trigger(.effect1)
//        ^~~~~~~
// ```
// To fix it just call `then` before the other effects commands
// ```
// case .event:
//     return then()
//         .trigger(.effect)
//         .stayOnCurrentState()
// ```
//
// ### Forgetting to call goTo or stayOnCurrentState
//
// If you forget to call `goTo` or `stayOnCurrentState`
// ```
// case .event:
//     return then()
//         .trigger(.effect)
// ```
// You will get an error similar to this one
// ```
// error: type of expression is ambiguous without more context
// .trigger(.effect1)
//          ~^~~~~~~
// ```
// To fix it just call `goTo` or `stayOnCurrentState` after the other effects commands
// ```
// case .event:
//     return then()
//         .trigger(.effect)
//         .stayOnCurrentState()
// ```
