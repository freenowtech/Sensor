//
//  SingleStateStateMachineTests.swift
//  SensorTestUnitTests
//
//  Created by Ferran Pujol Camins on 15/05/2019.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import Sensor
import SensorTest

enum Event: Equatable {
    case event1
    case event2
    case event3
    case event4
    case event5
    case eventTakingAHandle(EffectHandle<Effect>)
}

indirect enum Effect: Hashable {
    case effect1
    case effect2
    case effect3
    case effectTakingAHandle(EffectHandle<Self>)
}

struct State: Hashable {
    enum `Case`: Hashable {
        case state1
        case state2
    }

    let `case`: Case
    let effectHandle1: EffectHandle<Effect>?

    init(_ case: State.Case,
         effectHandle1: EffectHandle<Effect>? = nil) {

        self.case = `case`
        self.effectHandle1 = effectHandle1
    }

    init(_ state: Self,
         effectHandle1: EffectHandle<Effect>?? = nil) {

        self.case = state.case
        self.effectHandle1 = effectHandle1 ?? state.effectHandle1
    }

    static var state1: State {
        State(Case.state1)
    }

    static var state2: State {
        State(Case.state2)
    }
}

class SingleStateStateMachineTests: XCTestCase, SensorTestCase {

    var scheduler: TestScheduler!
    var triggeredEffects: PublishSubject<Effect>!

    func TestFeature(
        reducer: @escaping (State, Event) -> ValidEffectsDSL<State, Effect>,
        effectsImplementation: @escaping (Effect) -> Signal<Event>
    ) -> SensorFeatureInternal<State, Effect, Event> {
        SensorFeatureInternal(
            reducer: Reducer(reduce: reducer),
            effectsImplementation: EffectsImplementation<Effect, Event> { (effect) -> Signal<Event> in
                self.triggeredEffects.onNext(effect)
                return effectsImplementation(effect)
            }
        )
    }

    override func setUp() {
        scheduler = TestScheduler(initialClock: 0, resolution: 1, simulateProcessingDelay: false)
        triggeredEffects = PublishSubject<Effect>()
    }

    let statesDefinitions: [String: State] = [
        "1": .state1,
        "2": .state2,
    ]

    let eventsDefinitions: [String: Event] = [
        "1": .event1,
        "2": .event2,
        "3": .event3,
        "4": .event4,
        "5": .event5,
    ]

    let effectsDefinitions: [String: Effect] = [
        "1": .effect1,
        "2": .effect2,
        "3": .effect3,
    ]

    func testSingleStateStateMachine() {
        SharingScheduler.mock(scheduler: scheduler) {
            let expectations = [
                "The initial state must be emited on subscription.": [0],
                "The event must transition from .stat1 to .state1 when input is received.": [2, 5],
                "The event must trigger the effect when input is received.": [2, 5],
                "The same effect can be triggered a second time after.": [2, 5],
                // TODO: the expectation is not listed with the error on this failing case!
            ]
            let expectedEffectHandlesValues = [
                "0": [EffectHandle<Effect>(0, .effect1)],
                "1": [EffectHandle<Effect>(1, .effect1)],
                "b": [EffectHandle<Effect>(0, .effect1), EffectHandle<Effect>(1, .effect1)],
                "e": []
            ]

            //                                                                   012345
            let inputDefinition                          = Definition(timeline: "--1--1", values: eventsDefinitions)
            let expectedEventsDefintion                  = Definition(timeline: "--1--1", values: eventsDefinitions)
            let expectedStatesDefinition                 = Definition(timeline: "1-1--1", values: statesDefinitions, expectations: expectations)
            let expectedTriggeredEffectHandlesDefinition = Definition(timeline: "--0--1", values: expectedEffectHandlesValues, expectations: expectations)
            let expectedTriggeredEffectsDefinition       = Definition(timeline: "--1--1", values: effectsDefinitions, expectations: expectations)
            let expectedOngoingEffectHandlesDefinition   = Definition(timeline: "e-0--b", values: expectedEffectHandlesValues, expectations: expectations)

            let feature = TestFeature(
                reducer: { state, event in
                    switch (state.case, event) {
                    case (.state1, .event1):
                        return then()
                            .trigger(.effect1)
                            .goTo(state)

                    default:
                        return then().goTo(state)
                    }
                },
                effectsImplementation: { effect in
                    .never()
                }
            )

            let input = hotSignal(inputDefinition)
            let outputs = feature.privateTestOutputs(initialState: .state1, inputEvents: input)

            assert(outputs.states, isEqualTo: expectedStatesDefinition)
                .assert(outputs.events, isEqualTo: expectedEventsDefintion)
                .assert(outputs.ongoingEffectsHandles, isEqualTo: expectedOngoingEffectHandlesDefinition)
                .assert(triggeredEffects, isEqualTo: expectedTriggeredEffectsDefinition)
                .assert(outputs.triggeredEffectsHandles, isEqualTo: expectedTriggeredEffectHandlesDefinition)
                .runTest()
        }
    }

    func testEffectsNotCanceledOnNewState() {
        SharingScheduler.mock(scheduler: scheduler) {
            // When a second input event is received [4] then...
            let expectations = [
                "The triggered effect [2] is not canceled and its event received.": [6]
            ]
            let expectedEffectHandlesValues = [
                "0": [EffectHandle<Effect>(0, .effect1)],
                "e": []
            ]

            //                                                                   01234567
            let inputDefinition                          = Definition(timeline: "--1-2---", values: eventsDefinitions)
            let expectedEventsDefintion                  = Definition(timeline: "--1-2-2-", values: eventsDefinitions)
            let expectedStatesDefinition                 = Definition(timeline: "1-1-1-1-", values: statesDefinitions, expectations: expectations)
            let expectedTriggeredEffectHandlesDefinition = Definition(timeline: "--0-e-e-", values: expectedEffectHandlesValues, expectations: expectations)
            let expectedTriggeredEffectsDefinition       = Definition(timeline: "--1-----", values: effectsDefinitions, expectations: expectations)
            let expectedOngoingEffectHandlesDefinition   = Definition(timeline: "e-0-0-0-", values: expectedEffectHandlesValues, expectations: expectations)
            // TODO: ongoing effects should become empty once the effect fires here  ->|<-
            let effectSingleDefinition                   = Definition(timeline: "  ----2| ", values: eventsDefinitions)

            let feature = TestFeature(
                reducer: { state, event in
                    switch (state.case, event) {
                    case (.state1, .event1):
                        return then()
                            .trigger(.effect1)
                            .goTo(state)

                    default:
                        return then().goTo(state)
                    }
                },
                effectsImplementation: { effect in
                    switch effect {
                    case .effect1:
                        return self.coldSignal(effectSingleDefinition)

                    default:
                        return .never()
                    }
                }
            )
            let input = hotSignal(inputDefinition)
            let outputs = feature.privateTestOutputs(initialState: .state1, inputEvents: input)

            assert(outputs.states, isEqualTo: expectedStatesDefinition)
                .assert(outputs.events, isEqualTo: expectedEventsDefintion)
                .assert(outputs.ongoingEffectsHandles, isEqualTo: expectedOngoingEffectHandlesDefinition)
                .assert(triggeredEffects, isEqualTo: expectedTriggeredEffectsDefinition)
                .assert(outputs.triggeredEffectsHandles, isEqualTo: expectedTriggeredEffectHandlesDefinition)
                .runTest()
        }
    }

    func testTriggerEffectTwiceAtSameTime() {
        SharingScheduler.mock(scheduler: scheduler) {
            let expectations = [
                "Both effects must be triggered and their effects received": [2, 4],
                // TODO: the expectation is not listed with the error on this failing case!
            ]
            let expectedEffectHandlesValues = [
                "0": [EffectHandle<Effect>(0, .effect1), EffectHandle<Effect>(1, .effect1)],
                "e": []
            ]

            //                                                                   01 2  3 4
            let inputDefinition                          = Definition(timeline: "-- 1  - -  ", values: eventsDefinitions)
            let expectedEventsDefintion                  = Definition(timeline: "-- 1  -(22)", values: eventsDefinitions)
            let expectedStatesDefinition                 = Definition(timeline: "1- 1  -(11)", values: statesDefinitions, expectations: expectations)
            let expectedTriggeredEffectHandlesDefinition = Definition(timeline: "-- 0  -(ee)", values: expectedEffectHandlesValues, expectations: expectations)
            let expectedTriggeredEffectsDefinition       = Definition(timeline: "--(11)- -  ", values: effectsDefinitions, expectations: expectations)
            let expectedOngoingEffectsDefinition         = Definition(timeline: "e- 0  -(00)", values: expectedEffectHandlesValues, expectations: expectations)
            let effectSingleDefinition                   = Definition(timeline: "   -  - 2  ", values: eventsDefinitions)

            let feature = TestFeature(reducer: { state, event in
                switch (state.case, event) {
                case (.state1, .event1):
                    return then()
                        .trigger(.effect1, .effect1)
                        .stayOnCurrentState()

                default:
                    return then().goTo(state)
                }
            }, effectsImplementation: { effect in
                switch effect {
                case .effect1:
                    return self.coldSignal(effectSingleDefinition)

                default: return .never()
                }
            })
            let input = hotSignal(inputDefinition)
            let outputs = feature.privateTestOutputs(initialState: .state1, inputEvents: input)

            assert(outputs.states, isEqualTo: expectedStatesDefinition)
                .assert(outputs.events, isEqualTo: expectedEventsDefintion)
                .assert(outputs.ongoingEffectsHandles, isEqualTo: expectedOngoingEffectsDefinition)
                .assert(triggeredEffects, isEqualTo: expectedTriggeredEffectsDefinition)
                .assert(outputs.triggeredEffectsHandles, isEqualTo: expectedTriggeredEffectHandlesDefinition)
                .runTest()
        }
    }

    func testEffectCanTriggerItself() {
        SharingScheduler.mock(scheduler: scheduler) {
            let expectations = [
                "The effect event triggers the same effect again": [4],
                "The event of the second effect triggered is received": []
                // TODO: the expectation is not listed with the error on this failing case!
            ]
            let expectedEffectHandlesValues = [
                "0": [EffectHandle<Effect>(0, .effect1)],
                "1": [EffectHandle<Effect>(1, .effect1)],
                "2": [EffectHandle<Effect>(2, .effect1)],
                "b": [EffectHandle<Effect>(0, .effect1), EffectHandle<Effect>(1, .effect1)],
                "t": [EffectHandle<Effect>(0, .effect1), EffectHandle<Effect>(1, .effect1), EffectHandle<Effect>(2, .effect1)],
                "e": []
            ]
            //                                                                     0123456
            let inputDefinition                          = Definition(timeline: "--1----", values: eventsDefinitions)
            let expectedEventsDefintion                  = Definition(timeline: "--1-1-1", values: eventsDefinitions)
            let expectedStatesDefinition                 = Definition(timeline: "1-1-1-1", values: statesDefinitions, expectations: expectations)
            let expectedTriggeredEffectHandlesDefinition = Definition(timeline: "--0-1-2", values: expectedEffectHandlesValues, expectations: expectations)
            let expectedTriggeredEffectsDefinition       = Definition(timeline: "--1-1-1", values: effectsDefinitions, expectations: expectations)
            let expectedOngoingEffectHandlesDefinition   = Definition(timeline: "e-0-b-t", values: expectedEffectHandlesValues, expectations: expectations)
            let effectSignalDefinition                   = Definition(timeline: "  --1  ", values: eventsDefinitions)
            //                                                                         --1

            let feature = TestFeature(
                reducer: { state, event in
                    switch (state.case, event) {
                    case (.state1, .event1):
                        return then()
                            .trigger(.effect1)
                            .stayOnCurrentState()
                    default:
                        return stayOnCurrentState()
                    }
                },
                effectsImplementation: { effect in
                    switch effect {
                    case .effect1:
                        return self.coldSignal(effectSignalDefinition)

                    default: return .never()
                    }
                }
            )

            let input = hotSignal(inputDefinition)
            let outputs = feature.privateTestOutputs(initialState: .state1, inputEvents: input)

            assert(outputs.states, isEqualTo: expectedStatesDefinition)
                .assert(outputs.events, isEqualTo: expectedEventsDefintion)
                .assert(outputs.ongoingEffectsHandles, isEqualTo: expectedOngoingEffectHandlesDefinition)
                .assert(triggeredEffects, isEqualTo: expectedTriggeredEffectsDefinition)
                .assert(outputs.triggeredEffectsHandles, isEqualTo: expectedTriggeredEffectHandlesDefinition)
                .runTest(testUntil: 7)
        }
    }

    func testEffectsCanEmitSeveralEvents() {
        SharingScheduler.mock(scheduler: scheduler) {
            let expectations = [
                "An effect can emit several consecutive events asynchronously and we receive all of them": [4, 7],
                "When we get an event coming from an effect, the effect is not retriggered when the reducer issues the same() effect command.": [4],
                "When we get the last event coming from an effect, the effect is not retriggered when the reducer issues the same() effect command.": [7, 10]
            ]
            let expectedEffectHandlesValues = [
                "0": [EffectHandle<Effect>(0, .effect1)],
                "1": [EffectHandle<Effect>(1, .effect1)],
                "2": [EffectHandle<Effect>(2, .effect1)],
                "b": [EffectHandle<Effect>(0, .effect1), EffectHandle<Effect>(1, .effect1)],
                "t": [EffectHandle<Effect>(0, .effect1), EffectHandle<Effect>(1, .effect1), EffectHandle<Effect>(2, .effect1)],
                "e": []
            ]
            //                                                                     01234567890
            let inputDefinition                          = Definition(timeline: "--1--------", values: eventsDefinitions)
            let expectedEventsDefintion                  = Definition(timeline: "--1-2--2---", values: eventsDefinitions)
            let expectedStatesDefinition                 = Definition(timeline: "1-1-1--1---", values: statesDefinitions, expectations: expectations)
            let expectedTriggeredEffectHandlesDefinition = Definition(timeline: "--0-e--e---", values: expectedEffectHandlesValues, expectations: expectations)
            let expectedTriggeredEffectsDefinition       = Definition(timeline: "--1--------", values: effectsDefinitions, expectations: expectations)
            let expectedOngoingEffectHandlesDefinition   = Definition(timeline: "e-0-0--0---", values: expectedEffectHandlesValues, expectations: expectations)
            let effectSignalDefinition                   = Definition(timeline: "  --2--2---", values: eventsDefinitions)

            let feature = TestFeature(
                reducer: { state, event in
                    switch (state.case, event) {
                    case (.state1, .event1):
                        return then()
                            .trigger(.effect1)
                            .stayOnCurrentState()
                    default:
                        return stayOnCurrentState()
                    }
                },
                effectsImplementation: { effect in
                    switch effect {
                    case .effect1:
                        return self.coldSignal(effectSignalDefinition)

                    default: return .never()
                    }
                }
            )

            let input = hotSignal(inputDefinition)
            let outputs = feature.privateTestOutputs(initialState: .state1, inputEvents: input)

            assert(outputs.states, isEqualTo: expectedStatesDefinition)
                .assert(outputs.events, isEqualTo: expectedEventsDefintion)
                .assert(outputs.ongoingEffectsHandles, isEqualTo: expectedOngoingEffectHandlesDefinition)
                .assert(triggeredEffects, isEqualTo: expectedTriggeredEffectsDefinition)
                .assert(outputs.triggeredEffectsHandles, isEqualTo: expectedTriggeredEffectHandlesDefinition)
                .runTest()
        }
    }

    func testCancelAllEffects() {
        SharingScheduler.mock(scheduler: scheduler) {
            let expectations = [
                "All triggered events are canceled and their events are never received.": [2, 4, 5]
            ]
            let expectedEffectHandlesValues = [
                "b": [EffectHandle<Effect>(0, .effect1), EffectHandle<Effect>(1, .effect2)],
                "e": []
            ]
            //                                                                   01 2  34567
            let inputDefinition                          = Definition(timeline: "-- 1  -2---", values: eventsDefinitions)
            let expectedEventsDefintion                  = Definition(timeline: "-- 1  -2---", values: eventsDefinitions)
            let expectedStatesDefinition                 = Definition(timeline: "1- 1  -1---", values: statesDefinitions, expectations: expectations)
            let expectedTriggeredEffectHandlesDefinition = Definition(timeline: "-- b  -e---", values: expectedEffectHandlesValues, expectations: expectations)
            let expectedTriggeredEffectsDefinition       = Definition(timeline: "--(12)-----", values: effectsDefinitions, expectations: expectations)
            let expectedOngoingEffectHandlesDefinition   = Definition(timeline: "e- b  -e---", values: expectedEffectHandlesValues, expectations: expectations)
            let effectSignalDefinition                   = Definition(timeline: "   -  --1| ", values: eventsDefinitions)
            //                                                                      -  --1|

            let feature = TestFeature(
                reducer: { state, event in
                    switch (state.case, event) {
                    case (.state1, .event1):
                        return then()
                            .trigger(.effect1, .effect2)
                            .stayOnCurrentState()

                    case (.state1, .event2):
                        return then()
                            .cancelAllEffects()
                            .stayOnCurrentState()

                    default:
                        return stayOnCurrentState()
                    }
                },
                effectsImplementation: { effect in
                    return self.coldSignal(effectSignalDefinition)
                }
            )

            let input = hotSignal(inputDefinition)
            let outputs = feature.privateTestOutputs(initialState: .state1, inputEvents: input)

            assert(outputs.states, isEqualTo: expectedStatesDefinition)
                .assert(outputs.events, isEqualTo: expectedEventsDefintion)
                .assert(outputs.ongoingEffectsHandles, isEqualTo: expectedOngoingEffectHandlesDefinition)
                .assert(triggeredEffects, isEqualTo: expectedTriggeredEffectsDefinition)
                .assert(outputs.triggeredEffectsHandles, isEqualTo: expectedTriggeredEffectHandlesDefinition)
                .runTest()
        }
    }

    func testCancelSpecificEffect() {
        SharingScheduler.mock(scheduler: scheduler) {
            let expectations = [
                "All triggered events are canceled and their events are never received.": [2, 4, 5]
            ]
            let statesDefinitions: [String: State] = [
                "1": .state1,
                "H": State(.state1, effectHandle1: EffectHandle<Effect>(0, .effect1))
            ]
            let expectedEffectHandlesValues = [
                "1": [EffectHandle<Effect>(1, .effect2)],
                "b": [EffectHandle<Effect>(0, .effect1), EffectHandle<Effect>(1, .effect2)],
                "e": []
            ]
            //                                                                   01 2  34567
            let inputDefinition                          = Definition(timeline: "-- 1  -2---", values: eventsDefinitions)
            let expectedEventsDefintion                  = Definition(timeline: "-- 1  -2-4-", values: eventsDefinitions)
            let expectedStatesDefinition                 = Definition(timeline: "1- H  -1-1-", values: statesDefinitions, expectations: expectations)
            let expectedTriggeredEffectHandlesDefinition = Definition(timeline: "-- b  -e-e-", values: expectedEffectHandlesValues, expectations: expectations)
            let expectedTriggeredEffectsDefinition       = Definition(timeline: "--(12)-----", values: effectsDefinitions, expectations: expectations)
            let expectedOngoingEffectHandlesDefinition   = Definition(timeline: "e- b  -1-1-", values: expectedEffectHandlesValues, expectations: expectations)
            let effect1SignalDefinition                  = Definition(timeline: "   -  --3| ", values: eventsDefinitions)
            let effect2SignalDefinition                  = Definition(timeline: "   -  ---4| ", values: eventsDefinitions)

            let feature = TestFeature(
                reducer: { state, event in
                    switch (state.case, event) {
                    case (.state1, .event1):
                        return then()
                            .trigger(.effect1) { effectHandle1 in
                                then()
                                    .trigger(.effect2)
                                    .goTo(State(state, effectHandle1: effectHandle1))
                            }

                    case (.state1, .event2):
                        return then()
                            .cancel(state.effectHandle1!)
                            .goTo(.state1)

                    default:
                        return stayOnCurrentState()
                    }
                },
                effectsImplementation: { effect in
                    switch effect {
                    case .effect1:
                        return self.coldSignal(effect1SignalDefinition)
                    case .effect2:
                        return self.coldSignal(effect2SignalDefinition)
                    default:
                        return .never()
                    }
                }
            )

            let input = hotSignal(inputDefinition)
            let outputs = feature.privateTestOutputs(initialState: .state1, inputEvents: input)

            assert(outputs.states, isEqualTo: expectedStatesDefinition)
                .assert(outputs.events, isEqualTo: expectedEventsDefintion)
                .assert(outputs.ongoingEffectsHandles, isEqualTo: expectedOngoingEffectHandlesDefinition)
                .assert(triggeredEffects, isEqualTo: expectedTriggeredEffectsDefinition)
                .assert(outputs.triggeredEffectsHandles, isEqualTo: expectedTriggeredEffectHandlesDefinition)
                .runTest()
        }
    }

    func testStateCanBeSetInSecondTriggerClosure() {
        SharingScheduler.mock(scheduler: scheduler) {
            let expectations = [
                "The handle is saved in the state.": [2, 5, 6, 7]
            ]
            let statesDefinitions: [String: State] = [
                "1": .state1,
                "H": State(.state1, effectHandle1: EffectHandle<Effect>(2, .effect3))
            ]
            let expectedEffectHandlesValues = [
                "1": [EffectHandle<Effect>(1, .effect2)],
                "t": [EffectHandle<Effect>(0, .effect1), EffectHandle<Effect>(1, .effect2), EffectHandle<Effect>(2, .effect3)],
                "e": []
            ]
            //                                                                   01 2   345678
            let inputDefinition                          = Definition(timeline: "-- 1   ------", values: eventsDefinitions)
            let expectedEventsDefintion                  = Definition(timeline: "-- 1   --234-", values: eventsDefinitions)
            let expectedStatesDefinition                 = Definition(timeline: "1- H   --HHH-", values: statesDefinitions, expectations: expectations)
            let expectedTriggeredEffectHandlesDefinition = Definition(timeline: "-- t   --eee-", values: expectedEffectHandlesValues, expectations: expectations)
            let expectedTriggeredEffectsDefinition       = Definition(timeline: "--(123)------", values: effectsDefinitions, expectations: expectations)
            let expectedOngoingEffectHandlesDefinition   = Definition(timeline: "e- t   --ttt-", values: expectedEffectHandlesValues, expectations: expectations)
            let effect1SignalDefinition                  = Definition(timeline: "   -   --2|  ", values: eventsDefinitions)
            let effect2SignalDefinition                  = Definition(timeline: "   -   ---3| ", values: eventsDefinitions)
            let effect3SignalDefinition                  = Definition(timeline: "   -   ----4|", values: eventsDefinitions)

            let feature = TestFeature(
                reducer: { state, event in
                    switch (state.case, event) {
                    case (.state1, .event1):
                        return then()
                            .trigger(.effect1) { effectHandle1 in
                                then()
                                    .trigger(.effect2)
                            }
                            .trigger(.effect3) { effectHandle3 in
                                then()
                                    .goTo(State(state, effectHandle1: effectHandle3))
                            }

                    default:
                        return stayOnCurrentState()
                    }
                },
                effectsImplementation: { effect in
                    switch effect {
                    case .effect1:
                        return self.coldSignal(effect1SignalDefinition)
                    case .effect2:
                        return self.coldSignal(effect2SignalDefinition)
                    case .effect3:
                        return self.coldSignal(effect3SignalDefinition)
                    default:
                        return .never()
                    }
                }
            )

            let input = hotSignal(inputDefinition)
            let outputs = feature.privateTestOutputs(initialState: .state1, inputEvents: input)

            assert(outputs.states, isEqualTo: expectedStatesDefinition)
                .assert(outputs.events, isEqualTo: expectedEventsDefintion)
                .assert(outputs.ongoingEffectsHandles, isEqualTo: expectedOngoingEffectHandlesDefinition)
                .assert(triggeredEffects, isEqualTo: expectedTriggeredEffectsDefinition)
                .assert(outputs.triggeredEffectsHandles, isEqualTo: expectedTriggeredEffectHandlesDefinition)
                .runTest()
        }
    }

    func testStateCanBeSetInFirstTriggerClosure() {
        SharingScheduler.mock(scheduler: scheduler) {
            let expectations = [
                "The handle is saved in the state.": [2, 5, 6, 7]
            ]
            let statesDefinitions: [String: State] = [
                "1": .state1,
                "H": State(.state1, effectHandle1: EffectHandle<Effect>(0, .effect1))
            ]
            let expectedEffectHandlesValues = [
                "1": [EffectHandle<Effect>(1, .effect2)],
                "t": [EffectHandle<Effect>(0, .effect1), EffectHandle<Effect>(1, .effect2), EffectHandle<Effect>(2, .effect3)],
                "e": []
            ]
            //                                                                   01 2   345678
            let inputDefinition                          = Definition(timeline: "-- 1   ------", values: eventsDefinitions)
            let expectedEventsDefintion                  = Definition(timeline: "-- 1   --234-", values: eventsDefinitions)
            let expectedStatesDefinition                 = Definition(timeline: "1- H   --HHH-", values: statesDefinitions, expectations: expectations)
            let expectedTriggeredEffectHandlesDefinition = Definition(timeline: "-- t   --eee-", values: expectedEffectHandlesValues, expectations: expectations)
            let expectedTriggeredEffectsDefinition       = Definition(timeline: "--(123)------", values: effectsDefinitions, expectations: expectations)
            let expectedOngoingEffectHandlesDefinition   = Definition(timeline: "e- t   --ttt-", values: expectedEffectHandlesValues, expectations: expectations)
            let effect1SignalDefinition                  = Definition(timeline: "   -   --2|  ", values: eventsDefinitions)
            let effect2SignalDefinition                  = Definition(timeline: "   -   ---3| ", values: eventsDefinitions)
            let effect3SignalDefinition                  = Definition(timeline: "   -   ----4|", values: eventsDefinitions)

            let feature = TestFeature(
                reducer: { state, event in
                    switch (state.case, event) {
                    case (.state1, .event1):
                        return then()
                            .trigger(.effect1) { effectHandle1 in
                                then()
                                    .goTo(State(state, effectHandle1: effectHandle1))
                            }
                            .trigger(.effect2) { effectHandle3 in
                                then()
                                    .trigger(.effect3)
                            }

                    default:
                        return stayOnCurrentState()
                    }
                },
                effectsImplementation: { effect in
                    switch effect {
                    case .effect1:
                        return self.coldSignal(effect1SignalDefinition)
                    case .effect2:
                        return self.coldSignal(effect2SignalDefinition)
                    case .effect3:
                        return self.coldSignal(effect3SignalDefinition)
                    default:
                        return.never()
                    }
                }
            )

            let input = hotSignal(inputDefinition)
            let outputs = feature.privateTestOutputs(initialState: .state1, inputEvents: input)

            assert(outputs.states, isEqualTo: expectedStatesDefinition)
                .assert(outputs.events, isEqualTo: expectedEventsDefintion)
                .assert(outputs.ongoingEffectsHandles, isEqualTo: expectedOngoingEffectHandlesDefinition)
                .assert(triggeredEffects, isEqualTo: expectedTriggeredEffectsDefinition)
                .assert(outputs.triggeredEffectsHandles, isEqualTo: expectedTriggeredEffectHandlesDefinition)
                .runTest()
        }
    }

    func testEffectHandleCanBePassedToAnotherEffect() {
        SharingScheduler.mock(scheduler: scheduler) {
            let expectations = [
                "The handle can be passed to another effect.": [2],
                "The handle ends up in the reducer via the effect event.": [5]
            ]
            let statesDefinitions: [String: State] = [
                "1": .state1,
                "2": .state2,
                "H": State(.state1, effectHandle1: EffectHandle<Effect>(0, .effect1))
            ]
            let eventsDefinitions: [String: Event] = [
                "1": .event1,
                "2": .event2,
                "H": .eventTakingAHandle(EffectHandle<Effect>(0, .effect1))
            ]
            let effectsDefinitions: [String: Effect] = [
                "1": .effect1,
                "H": .effectTakingAHandle(EffectHandle<Effect>(0, .effect1))
            ]
            let expectedEffectHandlesValues = [
                "0": [EffectHandle<Effect>(0, .effect1)],
                "1": [EffectHandle<Effect>(1, .effectTakingAHandle(EffectHandle<Effect>(0, .effect1)))],
                "b": [EffectHandle<Effect>(0, .effect1),
                      EffectHandle<Effect>(1, .effectTakingAHandle(EffectHandle<Effect>(0, .effect1)))],
                "e": []
            ]
            //                                                                   01 2  345678
            let inputDefinition                          = Definition(timeline: "-- 1  ------", values: eventsDefinitions)
            let expectedEventsDefintion                  = Definition(timeline: "-- 1  --H-2-", values: eventsDefinitions)
            let expectedStatesDefinition                 = Definition(timeline: "1- 2  --H-2-", values: statesDefinitions, expectations: expectations)
            let expectedTriggeredEffectHandlesDefinition = Definition(timeline: "-- b  --e-e-", values: expectedEffectHandlesValues, expectations: expectations)
            let expectedTriggeredEffectsDefinition       = Definition(timeline: "--(1H)------", values: effectsDefinitions, expectations: expectations)
            let expectedOngoingEffectHandlesDefinition   = Definition(timeline: "e- b  --b-b-", values: expectedEffectHandlesValues, expectations: expectations)
            let effect1SignalDefinition                  = Definition(timeline: "   -  ----2|", values: eventsDefinitions)
            let effectTakingAHandleSignalDefinition      = Definition(timeline: "   -  --1|  ", values: eventsDefinitions)

            let feature = TestFeature(
                reducer: { state, event in
                    switch (state.case, event) {
                    case (.state1, .event1):
                        return then()
                            .trigger(.effect1) { effectHandle1 in
                                then()
                                    .trigger(.effectTakingAHandle(effectHandle1))
                        }
                        .goTo(.state2)

                    case (.state2, .eventTakingAHandle(let effectHandle)):
                        return then()
                            .goTo(State(.state1, effectHandle1: effectHandle))

                    case (.state1, .event2):
                        return then()
                            .goTo(.state2)

                    default:
                        return stayOnCurrentState()
                    }
                },
                effectsImplementation: { effect in
                    switch effect {
                    case .effect1:
                        return self.coldSignal(effect1SignalDefinition)
                    case .effectTakingAHandle(let handle):
                        return self.coldSignal(effectTakingAHandleSignalDefinition).map { _ in .eventTakingAHandle(handle) }
                    default:
                        return .never()
                    }
                }
            )

            let input = hotSignal(inputDefinition)
            let outputs = feature.privateTestOutputs(initialState: .state1, inputEvents: input)

            assert(outputs.states, isEqualTo: expectedStatesDefinition)
                .assert(outputs.events, isEqualTo: expectedEventsDefintion)
                .assert(outputs.ongoingEffectsHandles, isEqualTo: expectedOngoingEffectHandlesDefinition)
                .assert(triggeredEffects, isEqualTo: expectedTriggeredEffectsDefinition)
                .assert(outputs.triggeredEffectsHandles, isEqualTo: expectedTriggeredEffectHandlesDefinition)
                .runTest()
        }
    }

    // TODO: uncomment and fix this test
//    func testEffectHandlesAreRemovedOnCompletion() {
//        SharingScheduler.mock(scheduler: scheduler) {
//            let expectations = [
//                "The handle is removed on completion": [2, 5, 6, 7]
//            ]
//            let expectedEffectHandlesValues = [
//                "0": [EffectHandle<Effect>(0, .effect1)],
//                "1": [EffectHandle<Effect>(1, .effect2)],
//                "b": [EffectHandle<Effect>(0, .effect1), EffectHandle<Effect>(1, .effect2)],
//                "e": []
//            ]
//            //                                                                   01 2   3  456
//            let inputDefinition                          = Definition(timeline: "-- 1   -  -  ", values: eventsDefinitions)
//            let expectedEventsDefintion                  = Definition(timeline: "-- 1   2  3  ", values: eventsDefinitions)
//            let expectedStatesDefinition                 = Definition(timeline: "1- 1   1  1  ", values: statesDefinitions, expectations: expectations)
//            let expectedTriggeredEffectHandlesDefinition = Definition(timeline: "-- b   e  e  ", values: expectedEffectHandlesValues, expectations: expectations)
//            let expectedTriggeredEffectsDefinition       = Definition(timeline: "--(12) -  -  ", values: effectsDefinitions, expectations: expectations)
//            let expectedOngoingEffectHandlesDefinition   = Definition(timeline: "e- b   1  e  ", values: expectedEffectHandlesValues, expectations: expectations)
//            let effect1SignalDefinition                  = Definition(timeline: "   -  (2|)   ", values: eventsDefinitions)
//            let effect2SignalDefinition                  = Definition(timeline: "   -   - (3|)", values: eventsDefinitions)
//
//            let reducer = Reducer<State, Effect, Context, Event> { state, event in
//                switch (state.case, event) {
//                case (.state1, .event1):
//                    return then()
//                        .trigger(.effect1, .effect2)
//                        .sameState()
//
//                default:
//                    return sameState()
//                }
//            }
//
//            let effectsImplementation = testEffectsImplementation { effect, context in
//                switch effect {
//                case .effect1:
//                    return self.coldSignal(effect1SignalDefinition)
//                case .effect2:
//                    return self.coldSignal(effect2SignalDefinition)
//                default:
//                    return.never()
//                }
//            }
//
//            let context = Context()
//            let input = hotSignal(inputDefinition)
//            let outputs = reducer.privateTestOutputs(initialState: .state1,
//                                                     inputEvents: input,
//                                                     context: context,
//                                                     effectsImplementation: effectsImplementation)
//
//            assert(outputs.states, isEqualTo: expectedStatesDefinition)
//                .assert(outputs.events, isEqualTo: expectedEventsDefintion)
//                .assert(outputs.ongoingEffectsHandles, isEqualTo: expectedOngoingEffectHandlesDefinition)
//                .assert(context.triggeredEffects, isEqualTo: expectedTriggeredEffectsDefinition)
//                .assert(outputs.triggeredEffectsHandles, isEqualTo: expectedTriggeredEffectHandlesDefinition)
//                .runTest()
//        }
//    }
}
