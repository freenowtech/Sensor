// # 1. Introduction
//
// ## How to write a feature with Sensor 0.2.0
//
// In order to use Sensor you need to import the `Sensor` framework.
import Foundation
import RxCocoa
import Sensor

// We start by creating a Sensor Feature. A Sensor Feature groups all the code artifacts we need to write our feature.
// Our feature must conform to the `SensorFeature` protocol. The requirements of the protocol give us a blueprint of
// the code elements that compose our feature.
struct MyFeature: SensorFeature {

// First we need to define the possible states of our feature in a type named `State`.
// Notice how we didn't have to conform to any protocol. Any type can model our state.
    enum State {
        case idle
        case performingNetworkRequest
        case dataSent
    }

// Next step: define the input events of our feature in a type named `Event`.
// Again, notice how we didn't have to conform to any protocol. Any type can model our events.
    enum Event {
        case buttonPressed
        case requestSuccessful
    }

// Next step: define the effects of our feature in a type named `Effect`.
// We have a requirement for our `Effect` type: it must be `Hashable`.
    enum Effect: Hashable {
        case logSomething
        case performNetworkRequest
    }

// Now we have all we need to define the Reducer, which contains the logic of our feature.
    static let reducer: Reducer<State, Effect, Event>
// The `Reducer` type is just a wrapper over a `(State, Event) -> ValidEffectsDSL<State, Effect>` function.
// We'll see what this `ValidEffectsDSL` type is in a bit. Just think about this as a function that given
// the current state and the received event decides what's the next state and what effects should be triggered.
//
// Notice that `reducer` is a static property. The reason behind this is that the reducer must be a pure
// function. The fact that it is a static property helps you make sure you don't accidentally call or capture any
// property of your feature, thus you can be sure that your reducer only depends on the current state
// and the received event, and that all side-effects are encoded through the Effects type.
        = Reducer { state, event in
            switch (state, event) {
            case (.idle, .buttonPressed):
// In each switch case, we want to specify what the next state should be and what effects should be triggered.
// To do so, we use an [Embedded Domain Specific Language](https://en.wikipedia.org/wiki/Domain-specific_language#External_and_Embedded_Domain_Specific_Languages) that Sensor defines
// (or in less-fancy words: a bunch of functions that allow us to express something in a nice way,
// in this case we have a bunch of functions that help us define the next state and the effects that should be triggered).
//
// We always have to start calling the function `then()`. The `then` function is the 'entry-point' to the Sensor DSL.
            return then()
// Next, we specify what effects we want to trigger. We do so with the `trigger` method. Notice that this is a function that
// we have to call on the result of `then()`, hence the leading dot.
                .trigger(.logSomething, .performNetworkRequest)
// Last, we specify our next state. We do so with the `goTo` method.
//
// Notice above that we must return the object crated by `then` and the following `trigger` and `goTo` calls.
// This object is of type `ValidEffectsDSL<State, Effect>` (hence the `Reducer` has this return type)
// and is used internally by Sensor to know what effects to trigger, etc.
//
// The `then` function is needed for technical reasons, but it also improves code readability. For example, you can read this switch case like:
// *When state is idle and we receive the buttonPressed event, **then** we'll trigger the logSomething and
// performNetworkRequest effects and the next state will be performingNetworkRequest.*
                .goTo(.performingNetworkRequest)
//
            case (.performingNetworkRequest, .requestSuccessful):
// We can omit calls to `trigger` if we don't want to trigger any effect.
// However, we must always specify the next state by calling `goTo`. The only exception is when
// we use `stayOnCurrentState`, as described below.
                return then()
                    .goTo(.dataSent)
            default:
// When we don't want to change the current state nor trigger any effects, we can use the `stayOnCurrentState`
// function. It's a shorthand for `then().goTo(state)`
//
// Read *The Sensor DSL* section to know more details about the Sensor DSL and what things it allows you to do, such as triggering several effects or cancelling ongoing effects.
                return stayOnCurrentState()
            }
        }

// The last piece of our feature is the effects implementation. The effects implementation is were we
// tell Sensor what to do when a specific effect is triggered.
//
// For each effect we must execute the appropriate actions and return a `Signal`.
//
// Notice that `effectsImplementation` is not a static property: you can access properties of your feature
// as part of your effects implementation (you can find an example below).
    var effectsImplementation: EffectsImplementation<Effect, Event> {
        EffectsImplementation { [useCase] effect in
            switch effect {
            case .logSomething:
                print("Performing network request")
                return Signal.empty()

// We can of course use injected dependencies to implement a particular effect. Here, for example, we
// call a use case that has been provided to our feature and then map it to the appropriate event.
            case .performNetworkRequest:
                return useCase().map { _ in .requestSuccessful }
            }
        }
    }

    let useCase: () -> Signal<Void>
}


// ## Using a Sensor 0.2.0 feature
//
// In order to use a Feature, we first need to create an instance of it providing the needed dependencies.
let myFeature = MyFeature(
    useCase: {
        print("Network Request")
        return Signal.just(())
    }
)
// Now we can call the `outputStates` method of our feature to get the `Driver` of states. In order to do so, we need to specify the initial state and pass a `Signal`
// with the input events (in this example, it's just an empty signal).
let states = myFeature.outputStates(initialState: .idle, inputEvents: .empty())
// Now we can bind our view to the `states` `Driver`.

// TODO: complete this tutorial with a view bond to the state
