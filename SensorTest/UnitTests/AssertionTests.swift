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
          "Recorded timeline '-' is not equal to expected timeline 'e'",
          "Expected [next(e)] at time 0, but got [].",
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
          "Recorded timeline 'e' is not equal to expected timeline '-'",
          "Expected [] at time 0, but got [next(e)].",
          "SensorTest must work properly"
        ]
        """)
    }

    func testDifferentValue() {
        let inputTimeline    = "e"
        let expectedTimeline = "e"
        let inputValues    = ["e": "x"]
        let expectedValues = ["e": "v"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "Expected value 'e' to be 'v' at time 0, but got 'x'.",
          "SensorTest must work properly"
        ]
        """)
    }


    func testDifferentValueWithWhiteSpace() {
        let inputTimeline    = " e"
        let expectedTimeline = "e "
        let inputValues    = ["e": "x"]
        let expectedValues = ["e": "v"]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "Expected value 'e' to be 'v' at time 0, but got 'x'.",
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
        let expectedValues = ["e": S(s: "v")]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "Expected property 's' of value 'e' to be 'v' at time 0, but got 'x'.",
          "SensorTest must work properly"
        ]
        """)
    }

    func testDifferentSubValue2() {
        struct S: Equatable {
            let s: String
            let a = "a"
        }
        let inputTimeline   = "e"
        let inputValues    = ["e": S(s: "x")]
        let expectedTimeline = "e"
        let expectedValues = ["e": S(s: "v")]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "Expected property 's' of value 'e' to be 'v' at time 0, but got 'x'.",
          "SensorTest must work properly"
        ]
        """)
    }

    class O: Equatable {
        let s: String
        let a = "a"
        init(s: String) { self.s = s }
        static func == (lhs: O, rhs: O) -> Bool { return lhs.s == rhs.s }
    }

    func testDifferentObjectSubValue() {
        let inputTimeline   = "e"
        let inputValues    = ["e": O(s: "x")]
        let expectedTimeline = "e"
        let expectedValues = ["e": O(s: "v")]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "Expected property 's' of value 'e' to be 'v' at time 0, but got 'x'.",
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
        let expectedValues = ["e": T(s: S(s: "v"))]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: #"""
        [
          "value 'e' is not equal to the expected value at time 0",
          "SensorTest must work properly"
        ]
        """#)
    }

    func testDifferentSubSubValue2() {
        struct S: Equatable {
            let s: String
            let a = "a"
        }
        struct T: Equatable {
            let s: S
            let a = "a"
        }
        let inputTimeline   = "e"
        let inputValues    = ["e": T(s: S(s: "x"))]
        let expectedTimeline = "e"
        let expectedValues = ["e": T(s: S(s: "v"))]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: #"""
        [
          "value 'e' is not equal to the expected value at time 0",
          "SensorTest must work properly"
        ]
        """#)
    }


    func testDifferentSubSubValueWithCustomDescription() {
        struct WeirdString: Equatable, CustomStringConvertible {
            let s: String
            let description: String = "-"
        }

        struct S: Equatable {
            let s: WeirdString
        }

        let inputTimeline   = "e"
        let inputValues    = ["e": S(s: WeirdString(s: "x"))]
        let expectedTimeline = "e"
        let expectedValues = ["e": S(s: WeirdString(s: "v"))]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "value 'e' is not equal to the expected value at time 0",
          "SensorTest must work properly"
        ]
        """)
    }

    func testDifferentSubValueAndTimeline() {
        let inputTimeline   = "e"
        let inputValues    = ["e": ["s": "x"]]
        let expectedTimeline = "e--i"
        let expectedValues = ["e": ["s": "v"], "i": [:]]
        let expectations = [
            "SensorTest must work properly": [0],
            "SensorTest must be the best": [3]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: #"""
        [
          "Recorded timeline '¿' is not equal to expected timeline 'e--i'",
          "Expected property 's' of value 'e' to be 'v' at time 0, but got 'x'.",
          "SensorTest must work properly",
          "Expected [next([:])] at time 3, but got [].",
          "SensorTest must be the best"
        ]
        """#)
    }

    func testEnumDifferentCases() {
        enum S: Equatable {
            case a(String)
            case b(String)
        }
        let inputTimeline   = "e"
        let inputValues    = ["e": S.a("v")]
        let expectedTimeline = "e"
        let expectedValues = ["e": S.b("v")]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "Expected value 'e' to be 'b' at time 0, but got 'a'.",
          "SensorTest must work properly"
        ]
        """)
    }

    func testEnumDifferentSubvalues() {
        enum S: Equatable {
            case s(String)
        }
        let inputTimeline   = "e"
        let inputValues    = ["e": S.s("x")]
        let expectedTimeline = "e"
        let expectedValues = ["e": S.s("v")]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "Expected property 's' of value 'e' to be 'v' at time 0, but got 'x'.",
          "SensorTest must work properly"
        ]
        """)
    }

    func testEnumEqualSeveralSubvalues() {
        enum S: Equatable {
            case s(v: String, Int)
        }
        let inputTimeline   = "e"
        let inputValues    = ["e": S.s(v: "x", 0)]
        let expectedTimeline = "e"
        let expectedValues = ["e": S.s(v: "x", 0)]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

        ]
        """)
    }

    func testEnumDifferentSubvalues2() {
        enum S: Equatable {
            case s(v: String, Int)
        }
        let inputTimeline   = "e"
        let inputValues    = ["e": S.s(v: "x", 0)]
        let expectedTimeline = "e"
        let expectedValues = ["e": S.s(v: "v", 0)]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: #"""
        [
          "Expected property 'v' of value 'e' to be 'v' at time 0, but got 'x'.",
          "SensorTest must work properly"
        ]
        """#)
    }

    func testEnumSameComplexSubvalues() {
        struct T: Equatable {
            let a: Int
            let b: String
        }
        enum S: Equatable {
            case s(T)
        }
        let inputTimeline   = "e"
        let inputValues    = ["e": S.s(T(a: 0, b: "0"))]
        let expectedTimeline = "e"
        let expectedValues = ["e": S.s(T(a: 0, b: "0"))]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: #"""
        [

        ]
        """#)
    }


    func testEnumDifferentComplexSubvalues1() {
        struct T: Equatable {
            let a: Int
            let b: String
        }
        enum S: Equatable {
            case s(T)
        }
        let inputTimeline   = "e"
        let inputValues    = ["e": S.s(T(a: 0, b: "0"))]
        let expectedTimeline = "e"
        let expectedValues = ["e": S.s(T(a: 1, b: "0"))]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "Expected property 'a' of value 'e' to be '1' at time 0, but got '0'.",
          "SensorTest must work properly"
        ]
        """)
    }

    func testEnumDifferentComplexSubvalues2() {
        struct U: Equatable {
            let a: Int
            let b: Int
        }
        struct T: Equatable {
            let a: Int
            let b: U
        }
        enum S: Equatable {
            case s(T)
        }
        let inputTimeline   = "e"
        let inputValues    = ["e": S.s(T(a: 0, b: U(a: 0, b: 0)))]
        let expectedTimeline = "e"
        let expectedValues = ["e": S.s(T(a: 0, b: U(a: 0, b: 1)))]
        let expectations = [
            "SensorTest must work properly": [0]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, withValues: expectedValues, given: inputTimeline, withValues: inputValues, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "value 'e' is not equal to the expected value at time 0",
          "SensorTest must work properly"
        ]
        """)
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
          "Recorded timeline '-e' is not equal to expected timeline '-'",
          "Expected [] at time 1, but got [next(e)].",
          "SensorTest must work properly"
        ]
        """)
    }

    func testArraySingleElementTimeline() {
        let values: [String: [Int]] = ["a": [1], "b": [2]]
        let inputTimeline    = "a"
        let expectedTimeline = "b"
        let expectations = [
            "SensorTest must work properly": [1]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "Expected property '0' of value 'b' to be '2' at time 0, but got '1'."
        ]
        """)
    }

    func testSetSingleElementTimeline() {
        let values: [String: Set<Int>] = ["a": [1], "b": [2]]
        let inputTimeline    = "a"
        let expectedTimeline = "b"
        let expectations = [
            "SensorTest must work properly": [1]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "Expected property '0' of value 'b' to be '2' at time 0, but got '1'."
        ]
        """)
    }

    func testArraySeveralElementsTimeline() {
        let values: [String: [Int]] = ["a": [1, 2], "b": [1, 3]]
        let inputTimeline    = "a"
        let expectedTimeline = "b"
        let expectations = [
            "SensorTest must work properly": [1]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "Expected property '1' of value 'b' to be '3' at time 0, but got '2'."
        ]
        """)
    }

    func testSetSeveralElementsTimeline() {
        let values: [String: Set<Int>] = ["a": [1, 2], "b": [1, 3]]
        let inputTimeline    = "a"
        let expectedTimeline = "b"
        let expectations = [
            "SensorTest must work properly": [1]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "Expected property '1' of value 'b' to be '3' at time 0, but got '2'."
        ]
        """)
    }

    func testSetSeveralElementsTimelineAssertionSuccessful() {
        let values: [String: Set<Int>] = ["a": [1, 2], "b": [2, 1]]
        let inputTimeline    = "a"
        let expectedTimeline = "b"
        let expectations = [
            "SensorTest must work properly": [1]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

        ]
        """)
    }

    func testOptionalTimeline() {
        let values = ["i": 1, "n": nil]
        let inputTimeline    = "i"
        let expectedTimeline = "n"
        let expectations = [
            "SensorTest must work properly": [1]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [
          "Expected value 'n' to be 'nil' at time 0, but got 'Optional(1)'."
        ]
        """)
    }

    func testOptionalNilTimelineAssertionSuccessful() {
        let values = ["i": 1, "n": nil]
        let inputTimeline    = "n"
        let expectedTimeline = "n"
        let expectations = [
            "SensorTest must work properly": [1]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

        ]
        """)
    }

    func testOptionalValueTimelineAssertionSuccessful() {
        let values = ["i": 1, "n": nil]
        let inputTimeline    = "i"
        let expectedTimeline = "i"
        let expectations = [
            "SensorTest must work properly": [1]
        ]

        let failures = self.failures(forExpectedTimeline: expectedTimeline, given: inputTimeline, withValues: values, expectations: expectations)

        _assertInlineSnapshot(matching: failures, as: .json, with: """
        [

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
          "Recorded timeline '(ee)' is not equal to expected timeline 'e'",
          "Expected [next(e)] at time 0, but got [next(e), next(e)].",
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
          "Recorded timeline 'e' is not equal to expected timeline '(ee)'",
          "Expected [next(e), next(e)] at time 0, but got [next(e)].",
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
          "Expected [next(x), next(x)] at time 0, but got [next(e), next(e)].",
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
          "Recorded timeline '(ee)--(eee)-|' is not equal to expected timeline '(ee)--(ee)-|'",
          "Expected [next(e), next(e)] at time 3, but got [next(e), next(e), next(e)]."
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
          "Recorded timeline '#' is not equal to expected timeline '-'",
          "Expected [] at time 0, but got [error(AnyError())].",
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
          "Recorded timeline '-' is not equal to expected timeline '#'",
          "Expected [error(AnyError())] at time 0, but got [].",
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
          "Recorded timeline '(e#)' is not equal to expected timeline '-'",
          "Expected [] at time 0, but got [next(e), error(AnyError())].",
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
          "Recorded timeline '-' is not equal to expected timeline '(e#)'",
          "Expected [next(e), error(AnyError())] at time 0, but got [].",
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
          "Recorded timeline 'x' is not equal to expected timeline '-'",
          "Expected [] at time 0, but got [error(Error Domain=someError Code=9 \"(null)\")].",
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
          "Recorded timeline '-' is not equal to expected timeline 'x'",
          "Expected [error(Error Domain=someError Code=9 \"(null)\")] at time 0, but got [].",
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
          "Recorded timeline '(ex)' is not equal to expected timeline '-'",
          "Expected [] at time 0, but got [next(e), error(Error Domain=someError Code=9 \"(null)\")].",
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
          "Recorded timeline '-' is not equal to expected timeline '(ex)'",
          "Expected [next(e), error(Error Domain=someError Code=9 \"(null)\")] at time 0, but got [].",
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
          "Recorded timeline '|' is not equal to expected timeline '-'",
          "Expected [] at time 0, but got [completed].",
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
          "Recorded timeline '-' is not equal to expected timeline '|'",
          "Expected [completed] at time 0, but got [].",
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
          "Recorded timeline '(e|)' is not equal to expected timeline '-'",
          "Expected [] at time 0, but got [next(e), completed].",
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
          "Recorded timeline '-' is not equal to expected timeline '(e|)'",
          "Expected [next(e), completed] at time 0, but got [].",
          "SensorTest must work properly"
        ]
        """)
    }
}
