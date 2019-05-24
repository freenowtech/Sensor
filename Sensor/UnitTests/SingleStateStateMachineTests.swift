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

enum NoEffects: TriggerableEffect {
    func trigger(context: Void) -> Signal<Void> {
        return Signal.never()
    }
}

enum SingleState: ReducibleStateWithEffects {
    func reduce(event: NoEffects.Event) -> (state: SingleState, effects: Set<NoEffects>) {
        return (state: self, effects: Set())
    }
    case theOneState
}

class SingleStateStateMachineTests: XCTestCase, SensorTestCase {

    var scheduler: TestScheduler!

    override func setUp() {
        scheduler = TestScheduler(initialClock: 0, resolution: 1, simulateProcessingDelay: false)
    }

    func testInitialStateEmission() {
        SharingScheduler.mock(scheduler: scheduler) {
            let requirements = [
                0: "The initial state must be emited on subscription.",
                2: "The event must transition from .theOneState to .theOneState."
            ]

            let inputDefinition            = (timeline: "---i", values: ["i": ()])
            let expectedStatesDefinition   = (timeline: "s-s", values: ["s": SingleState.theOneState], requirements: requirements)

            let input = hotSignal(inputDefinition)
            let states = SingleState.outputStates(initialState: .theOneState, inputEvents: input, context: ())

            assert(states, isEqualTo: expectedStatesDefinition)
                .withScheduler(scheduler)
        }
    }
}
