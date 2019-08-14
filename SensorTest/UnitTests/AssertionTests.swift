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
        let inputTimeline    = "-"
        let expectedTimeline = "e"
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "- is not equal to e",
          "Expected [next(e)] at 0, but got [].",
          "SensorTest must work properly"
        ]
        """)
    }

    func testUnexpectedEvents() {
        let values = ["e": "e"]
        let inputTimeline    = "e"
        let expectedTimeline = "-"
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "e is not equal to -",
          "Expected [] at 0, but got [next(e)].",
          "SensorTest must work properly"
        ]
        """)
    }

    func testDifferentValue() {
        let inputTimeline    = "e"
        let expectedTimeline = "e"
        let inputValues    = ["e": "x"]
        let expectedValues = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "¿ is not equal to e",
          "Expected e at 0, but got x.",
          "SensorTest must work properly"
        ]
        """)
    }


    func testDifferentValueWithWhiteSpace() {
        let inputTimeline    = " e"
        let expectedTimeline = "e "
        let inputValues    = ["e": "x"]
        let expectedValues = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "¿ is not equal to e",
          "Expected e at 0, but got x.",
          "SensorTest must work properly"
        ]
        """)
    }

    func testDifferentSubValue() {
        struct S: Equatable {
            let s: String
        }
        let inputTimeline   = "e"
        let inputValues    = ["e": S(s: "x")]
        let expectedTimeline = "e"
        let expectedValues = ["e": S(s: "e")]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "¿ is not equal to e",
          "Expected s to be x at 0, but got e.",
          "SensorTest must work properly"
        ]
        """)
    }

    class O: Equatable {
        let s: String
        init(s: String) { self.s = s }
        static func == (lhs: O, rhs: O) -> Bool { return lhs.s == rhs.s }
    }

    func testDifferentObjectSubValue() {
        let inputTimeline   = "e"
        let inputValues    = ["e": O(s: "x")]
        let expectedTimeline = "e"
        let expectedValues = ["e": O(s: "e")]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "¿ is not equal to e",
          "Expected s to be x at 0, but got e.",
          "SensorTest must work properly"
        ]
        """)
    }

    func testDifferentSubSubValue() {
        struct S: Equatable {
            let s: String
        }
        struct T: Equatable {
            let s: S
        }
        let inputTimeline   = "e"
        let inputValues    = ["e": T(s: S(s: "x"))]
        let expectedTimeline = "e"
        let expectedValues = ["e": T(s: S(s: "e"))]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: #"""
        [
          "¿ is not equal to e",
          "Expected s to be S(s: \"x\") at 0, but got S(s: \"e\").",
          "SensorTest must work properly"
        ]
        """#)
    }

    func testDifferentSubValueAndTimeline() {
        let inputTimeline   = "e"
        let inputValues    = ["e": ["s": "x"]]
        let expectedTimeline = "e--i"
        let expectedValues = ["e": ["s": "e"], "i": [:]]
        let expectations = [
            "SensorTest must work properly": [0],
            "SensorTest must be the best": [3]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: #"""
        [
          "¿ is not equal to e--i",
          "Expected [\"s\": \"e\"] at 0, but got [\"s\": \"x\"].",
          "SensorTest must work properly",
          "Expected [next([:])] at 3, but got [].",
          "SensorTest must be the best"
        ]
        """#)
    }

    func testEnumSubvalues() {
        XCTFail()
    }

    func testDifferentLengthTimeline() {
        let values = ["e": "e"]
        let inputTimeline    = "-e"
        let expectedTimeline = "-"
        let expectations = [
            "SensorTest must work properly": [1]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "-e is not equal to -",
          "Expected [] at 1, but got [next(e)].",
          "SensorTest must work properly"
        ]
        """)
    }

    func testSameTimelineDifferentEventNames() {
        let inputValues    = ["i": "x"]
        let expectedValues = ["e": "x"]
        let inputTimeline    = "-i"
        let expectedTimeline = "-e"
        let expectations = [
            "SensorTest must work properly": [1]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)
        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

        ]
        """)
    }

    func testSeveralEventsSameTimeAssertionSuccessful() {
        // The order must not affect the success of the assertion
        let inputTimeline    = "(ea)"
        let expectedTimeline = "(ae)"
        let values = ["e": "e", "a": "a"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

        ]
        """)
    }

    func testSeveralEventsSameTimeMissingEvent() {
        let inputTimeline    = "(ee)"
        let expectedTimeline = "e"
        let inputValues    = ["e": "e"]
        let expectedValues = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "(ee) is not equal to e",
          "Expected [next(e)] at 0, but got [next(e), next(e)].",
          "SensorTest must work properly"
        ]
        """)
    }

    func testSeveralEventsSameTimeUnexpectedEvent() {
        let inputTimeline    = "e"
        let expectedTimeline = "(ee)"
        let inputValues    = ["e": "e"]
        let expectedValues = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "e is not equal to (ee)",
          "Expected [next(e), next(e)] at 0, but got [next(e)].",
          "SensorTest must work properly"
        ]
        """)
    }

    func testSeveralEventsSameTimeDifferentEvents() {
        let inputTimeline    = "(ee)"
        let expectedTimeline = "(ee)"
        let inputValues    = ["e": "e"]
        let expectedValues = ["e": "x"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "(¿¿) is not equal to (ee)",
          "Expected [next(x), next(x)] at 0, but got [next(e), next(e)].",
          "SensorTest must work properly"
        ]
        """)
    }


    func testSeveralEventsSameTimeSeveralGroupsAssertionSuccessful() {
        let inputTimeline    = "(ee)--(eee)-|"
        let expectedTimeline = "(ee)--(eee)-|"
        let inputValues    = ["e": "e"]
        let expectedValues = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

        ]
        """)
    }

    func testSeveralEventsSameTimeSeveralGroupsMissingElement() {
        //               Time:   0  12 3   45
        let inputTimeline    = "(ee)--(eee)-|"
        let expectedTimeline = "(ee)--(ee) -|"
        let inputValues    = ["e": "e"]
        let expectedValues = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0],
            "SensorTest must be the best": [5]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "(ee)--(eee)-| is not equal to (ee)--(ee)-|",
          "Expected [next(e), next(e)] at 3, but got [next(e), next(e), next(e)]."
        ]
        """)
    }

    func testUnknownErrorSuccess() {
        let inputTimeline    = "#"
        let expectedTimeline = "#"
        let values = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [1]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

        ]
        """)
    }

    func testUnknownErrorMatchesAnyError() {
        let inputTimeline    = "x"
        let expectedTimeline = "#"
        let values = ["e": "e"]
        let errors = ["x": NSError(domain: "someError", code: 9, userInfo: nil)]
        let expectations = [
            "SensorTest must work properly": [1]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, andInputErrors: errors, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

        ]
        """)
    }

    func testUnknownErrorMatchesAnyErrorWithOtherEvents() {
        let inputTimeline    = "(ex)"
        let expectedTimeline = "(e#)"
        let values = ["e": "e"]
        let errors = ["x": NSError(domain: "someError", code: 9, userInfo: nil)]
        let expectations = [
            "SensorTest must work properly": [1]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, andInputErrors: errors, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

        ]
        """)
    }

    func testUnexpectedUnknownError() {
        let inputTimeline    = "#"
        let expectedTimeline = "-"
        let values = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "# is not equal to -",
          "Expected [] at 0, but got [error(AnyError())].",
          "SensorTest must work properly"
        ]
        """)
    }

    func testMissingUnknownError() {
        let inputTimeline    = "-"
        let expectedTimeline = "#"
        let values = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "- is not equal to #",
          "Expected [error(AnyError())] at 0, but got [].",
          "SensorTest must work properly"
        ]
        """)
    }

    func testUnkownErrorWithEventSuccess() {
        let inputTimeline    = "(e#)"
        let expectedTimeline = "(e#)"
        let values = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

        ]
        """)
    }

    func testUnexpectedUnknownErrorWithEvent() {
        let inputTimeline    = "(e#)"
        let expectedTimeline = "-"
        let values = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "(e#) is not equal to -",
          "Expected [] at 0, but got [next(e), error(AnyError())].",
          "SensorTest must work properly"
        ]
        """)
    }

    func testMissingUnknownErrorWithEvent() {
        let inputTimeline    = "-"
        let expectedTimeline = "(e#)"
        let values = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "- is not equal to (e#)",
          "Expected [next(e), error(AnyError())] at 0, but got [].",
          "SensorTest must work properly"
        ]
        """)
    }

    func testUnexpectedError() {
        let inputTimeline    = "x"
        let expectedTimeline = "-"
        let values = ["e": "e"]
        let errors = ["x": NSError(domain: "someError", code: 9, userInfo: nil)]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, andExpectedErrors: errors, given: inputTimeline, withValues: values, andInputErrors: errors, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: #"""
        [
          "x is not equal to -",
          "Expected [] at 0, but got [error(Error Domain=someError Code=9 \"(null)\")].",
          "SensorTest must work properly"
        ]
        """#)
    }

    func testMissingError() {
        let inputTimeline    = "-"
        let expectedTimeline = "x"
        let values = ["e": "e"]
        let errors = ["x": NSError(domain: "someError", code: 9, userInfo: nil)]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, andExpectedErrors: errors, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: #"""
        [
          "- is not equal to x",
          "Expected [error(Error Domain=someError Code=9 \"(null)\")] at 0, but got [].",
          "SensorTest must work properly"
        ]
        """#)
    }

    func testErrorWithEventSuccess() {
        let inputTimeline    = "(ex)"
        let expectedTimeline = "(ex)"
        let values = ["e": "e"]
        let errors = ["x": NSError(domain: "someError", code: 9, userInfo: nil)]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, andExpectedErrors: errors, given: inputTimeline, withValues: values, andInputErrors: errors, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

        ]
        """)
    }

    func testUnexpectedErrorWithEvent() {
        let inputTimeline    = "(ex)"
        let expectedTimeline = "-"
        let values = ["e": "e"]
        let errors = ["x": NSError(domain: "someError", code: 9, userInfo: nil)]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, andExpectedErrors: errors, given: inputTimeline, withValues: values, andInputErrors: errors, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: #"""
        [
          "(ex) is not equal to -",
          "Expected [] at 0, but got [next(e), error(Error Domain=someError Code=9 \"(null)\")].",
          "SensorTest must work properly"
        ]
        """#)
    }

    func testMissingErrorWithEvent() {
        let inputTimeline    = "-"
        let expectedTimeline = "(ex)"
        let values = ["e": "e"]
        let errors = ["x": NSError(domain: "someError", code: 9, userInfo: nil)]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, andExpectedErrors: errors, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: #"""
        [
          "- is not equal to (ex)",
          "Expected [next(e), error(Error Domain=someError Code=9 \"(null)\")] at 0, but got [].",
          "SensorTest must work properly"
        ]
        """#)
    }

    func testCompletionSuccess() {
        let inputTimeline    = "|"
        let expectedTimeline = "|"
        let values = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

        ]
        """)
    }

    func testUnexpectedCompletion() {
        let inputTimeline    = "|"
        let expectedTimeline = "-"
        let values = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "| is not equal to -",
          "Expected [] at 0, but got [completed].",
          "SensorTest must work properly"
        ]
        """)
    }

    func testMissingCompletion() {
        let inputTimeline    = "-"
        let expectedTimeline = "|"
        let values = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "- is not equal to |",
          "Expected [completed] at 0, but got [].",
          "SensorTest must work properly"
        ]
        """)
    }

    func testCompletionWithEventSuccess() {
        let inputTimeline    = "(e|)"
        let expectedTimeline = "(e|)"
        let values = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

        ]
        """)
    }

    func testUnexpectedCompletionWithEvent() {
        let inputTimeline    = "(e|)"
        let expectedTimeline = "-"
        let values = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "(e|) is not equal to -",
          "Expected [] at 0, but got [next(e), completed].",
          "SensorTest must work properly"
        ]
        """)
    }

    func testMissingCompletionWithEvent() {
        let inputTimeline    = "-"
        let expectedTimeline = "(e|)"
        let values = ["e": "e"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: values, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "- is not equal to (e|)",
          "Expected [next(e), completed] at 0, but got [].",
          "SensorTest must work properly"
        ]
        """)
    }
}
