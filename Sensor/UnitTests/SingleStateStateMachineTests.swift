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

struct Context {
    let triggeredEffects = PublishSubject<Effects>()

    init() {
        triggeredEffects.debug("R").subscribe().disposed(by: disposeBag)
    }

    private let disposeBag = DisposeBag()
}

enum Effects: TriggerableEffect {
    case effect

    func trigger(context: Context) -> Signal<Void> {
        context.triggeredEffects.onNext(self)
        return Signal.never()
    }
}

enum SingleState: ReducibleStateWithEffects {
    case theOneState

    func reduce(event: Effects.Event) -> (state: SingleState, effects: Set<Effects>) {
        return (state: self, effects: [.effect])
    }
}

class SingleStateStateMachineTests: XCTestCase, SensorTestCase {

    var scheduler: TestScheduler!

    override func setUp() {
        scheduler = TestScheduler(initialClock: 0, resolution: 1, simulateProcessingDelay: false)
    }

    func testSingleStateStateMachine() {
        SharingScheduler.mock(scheduler: scheduler) {
            let expectationsOnState = [
                "The initial state must be emited on subscription.": [0],
                "The event must transition from .theOneState to .theOneState when input is received.": [2, 5],
                // TODO: the expectation is not listed with the error on this failing case!
            ]

            let expectationsOnEffects = [
                "The event must trigger the effect when input is received.": [2, 5]
            ]

            let inputDefinition                    = (timeline: "--i--i", values: ["i": ()])
            let expectedStatesDefinition           = (timeline: "s-s--s", values: ["s": SingleState.theOneState], expectations: expectationsOnState)
            let expectedEffectsDefinition          = (timeline: "e-f--f", values: ["e": [], "f": Set([Effects.effect])], expectations: expectationsOnEffects)
            let expectedTriggeredEffectsDefinition = (timeline: "--f--f", values: ["f": Effects.effect], expectations: expectationsOnEffects)

            let context = Context()
            let input = hotSignal(inputDefinition)
            let outputs = SingleState.testOutputs(initialState: .theOneState, inputEvents: input, context: context)
            
            assert(outputs.states, isEqualTo: expectedStatesDefinition)
                .assert(outputs.effects, isEqualTo: expectedEffectsDefinition)
                .assert(context.triggeredEffects, isEqualTo: expectedTriggeredEffectsDefinition)
                .runTest()
        }
    }
}
