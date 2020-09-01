// # 3. What has changed from Sensor 0.1.0
//
import Foundation
import RxCocoa
import Sensor
// ## New Sensor DSL
//
// The Sensor DSL allows to express new ways to trigger and cancel effects that were not possible before:
//
// - When you trigger new effects, the ongoing effects are not cancelled.
// - You can cancel specific effects by storing an effect handle on the state.
//
// For more information read *The Sensor DSL section*.
//
// ## New SensorFeature, Reducer and EffectsImplementation types
// We added theses types to help developers remember what they need to implement in order to
// create a Sensor feature and improve code readability.
//
// The specific types also open the door to composition of reducers and features in the future,
// as seen in Pointfree's Composable Architecture and Bow Arch.
//
// ## Context is gone
//
// When building the outputs of a Sensor 0.1.0 feature we used to provide a Context object that was then passed
// to the effects `trigger` method.
// ```
// MyState.outputStates(initialState: .initialState, inputEvents: input, context: context)
// ```
//
// We used the context to inject use-cases into the effects `trigger` method, so side-effects were isolated from
// the logic of our feature and we could mock them in unit tests.
//
// This means that we needed to define the `Context` object with all the use-cases we needed,
// ```
// struct Context {
//     let useCase: () -> Void
// }
// ```
// and then write the effects `trigger` method to call those use-cases.
// ```
// enum Effect: TriggerableEffect {
//     case effect
//
//     func trigger(context: Context) -> Signal<Event> {
//         context.useCase()
//         return .empty()
//     }
// }
// ```
// But, why don't we merge both things? Why don't we unify the `Context` and the `trigger`
// method. This is where Sensor 0.2.0 `EffectsImplementation` comes from.
//
// The `Effects` type now does not require a `trigger` method, instead, a feature now is required to have an `EffectsImplementation`,
// which is nothing else than a closure. Converting `trigger` into an `EffectsImplementation` closure allows it to capture the use-cases
// it needs, thus the `Context` object is no longer needed.
//
// Now it's up the feature to decide how to build an `EffectsImplementation`.
// It can provide a fixed `EffectsImplementation` like this one:
enum MyEffect {
    case effect
}
enum Event {}
struct MyFeatureWithFixedEffects {
    var effectsImplementation: EffectsImplementation<MyEffect, Event> {
        EffectsImplementation { effect in
            switch effect {
            case .effect:
                print("Hello")
                return .empty()
            }
        }
    }
}
// Or maybe it's up the client code that uses the feature to provide an `EffectsImplementation`
struct MyFeatureWithInjectedEffects2 {
    init(_ effectsImplementation: EffectsImplementation<MyEffect, Event>) {
        self.effectsImplementation = effectsImplementation
    }
    let effectsImplementation: EffectsImplementation<MyEffect, Event>
}
// Or maybe the feature still requires a Context object to its clients, and internally transforms it into the `EffectsImplementation`.
struct MyFeatureWithInjectedEffects3 {
    struct Context {
        let useCase: () -> Void
    }
    init(_ context: Context) {
        self.context = context
    }
    let context: Context
        var effectsImplementation: EffectsImplementation<MyEffect, Event> {
        EffectsImplementation { [context] effect in
            switch effect {
            case .effect:
                context.useCase()
                return .empty()
            }
        }
    }
}
// ## ReducibleState is gone
//
// We used to have `ReducibleState`, a simpler version of `ReducibleStateWithEffects`
// that had no support for effects.
//
// If you wanted to implement a feature where you need no effects,
// `ReducibleStateWithEffects` was a bit verbose, because you still needed to specify an empty set of
// effects on the return value of each reducer case. `ReducibleState` solved this issue because it hasn't support for effects, so on each reducer case you only needed to return the next state.
//
// However, with the new Sensor DSL you are no longer required to specify an empty set of effects. When you don't want to trigger any effects, you just omit calls the `trigger` method. Thus, `ReducibleState` is no longer needed and it was removed.
//
// `ReducibleState` is still available as part of Sensor 0.1.0 in the `Sensor` framework.
