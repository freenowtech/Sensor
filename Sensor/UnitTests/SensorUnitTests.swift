//
//  SensorUnitTests.swift
//  SensorTestUnitTests
//
//  Created by Ferran Pujol Camins on 15/05/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import Sensor
import SensorTest

class SensorUnitTests: XCTestCase, SensorTestCase {

    var scheduler: TestScheduler!

    override func setUp() {
        scheduler = TestScheduler(initialClock: 0, resolution: 1, simulateProcessingDelay: false)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTrivialStateMachine() {
        enum Effects: TriggerableEffect {
            func trigger(context: Void) -> Signal<Void> {
                return Signal.never()
            }
        }

        enum State: ReducibleStateWithEffects {
            func reduce(event: Effects.Event) -> (state: State, effects: Set<Effects>) {
                return (state: self, effects: Set())
            }
            case theOneState
        }

        SharingScheduler.mock(scheduler: scheduler) {

            let states = State.testOutputs(initialState: .theOneState, inputEvents: Signal.never(), context: ()).states

            withScheduler(scheduler)
                .assert(states, isEqualToTimeline: "s", withValues: ["s": .theOneState])

        }
    }
}
