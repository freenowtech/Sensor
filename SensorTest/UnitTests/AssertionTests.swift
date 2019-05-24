//
//  AssertionTests.swift
//  SensorTestUnitTests
//
//  Created by Ferran Pujol Camins on 16/05/2019.
//

import XCTest
@testable import SensorTest
import RxSwift
import RxTest
import SnapshotTesting

class AssertionTests: XCTestCase, SensorTestCase {

    var scheduler: TestScheduler!

    override func setUp() {
        scheduler = TestScheduler(initialClock: 0, resolution: 1, simulateProcessingDelay: false)
    }

    func testMissingEvents() {
        let values = ["e": "e"]
        let inputTimeline   = "-"
        let expectedTimeline = "e"

        let failures = self.failures(forExpectedTimeline: expectedTimeline, given: inputTimeline, withValues: values)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "- is not equal to e"
        ]
        """)
    }

    func testUnexpectedEvents() {
        let values = ["e": "e"]
        let inputTimeline   = "e"
        let expectedTimeline = "-"

        let failures = self.failures(forExpectedTimeline: expectedTimeline, given: inputTimeline, withValues: values)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "e is not equal to -"
        ]
        """)
    }

    func testDifferentValue() {
        let inputTimeline   = "e"
        let inputValues    = ["e": "x"]
        let expectedTimeline = "e"
        let expectedValues = ["e": "e"]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "¿ is not equal to e",
          "Expected e at 0, but got x."
        ]
        """)
    }

    func testDifferentSubValue() {
        let inputTimeline   = "e"
        let inputValues    = ["e": ["s": "x"]]
        let expectedTimeline = "e"
        let expectedValues = ["e": ["s": "e"]]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues)

        _assertInlineSnapshot(matching: failures, as: .json, with: #"""
        [
          "¿ is not equal to e",
          "Expected [\"s\": \"e\"] at 0, but got [\"s\": \"x\"]."
        ]
        """#)
    }

    func testDifferentSubValueAndTimeline() {
        let inputTimeline   = "e"
        let inputValues    = ["e": ["s": "x"]]
        let expectedTimeline = "e--i"
        let expectedValues = ["e": ["s": "e"], "i": [:]]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues)

        _assertInlineSnapshot(matching: failures, as: .json, with: #"""
        [
          "¿ is not equal to e--i",
          "Expected [\"s\": \"e\"] at 0, but got [\"s\": \"x\"]."
        ]
        """#)
    }

    func testDifferentLengthTimeline() {
        let values = ["e": "e"]
        let inputTimeline   = "-e"
        let expectedTimeline = "-"

        let failures = self.failures(forExpectedTimeline: expectedTimeline, given: inputTimeline, withValues: values)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "-e is not equal to -"
        ]
        """)
    }

    func testSameTimelineDifferentEventNames() {
        let inputValues    = ["i": "x"]
        let expectedValues = ["e": "x"]
        let inputTimeline    = "-i"
        let expectedTimeline = "-e"

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues)
        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

        ]
        """)
    }

    func failures<V: Equatable>(forExpectedTimeline expectedTimeline: String, given inputTimeline: String, withValues values: [String: V]) -> [String] {
        return failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values)
    }

    func failures<V>(forExpectedTimeline expectedTimeline: String, withValues expectedValues: [String: V], given inputTimeline: String, withValues inputValues: [String: V]) -> [String] where V: Equatable {
        let observable = hotObservable(timeline: inputTimeline, values: inputValues)
        let (expectedStates, recordedStates) = TestMethod.parseAndRecord(observable, expectedTimeline: expectedTimeline, values: expectedValues, scheduler: scheduler, maxTime: Int.max)
        scheduler.start()
        return TestMethod.checkFailures(
            expectedStates: expectedStates,
            recordedStates: recordedStates,
            expectedTimeline: expectedTimeline,
            values: expectedValues
        )
    }
}
