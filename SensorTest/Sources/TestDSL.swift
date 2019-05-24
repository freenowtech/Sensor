//
//  TestDSL.swift
//  SensorTest
//
//  Created by Ferran Pujol Camins on 26/03/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import XCTest
import RxTest
import RxSwift

public typealias PreAssertion<V> = (_ scheduler: TestScheduler, _ maxTime: Int) -> V
public typealias Assertion<V> = (V) -> Void

internal typealias TypeErasedPreAssertion = (_ scheduler: TestScheduler, _ maxTime: Int) -> Any
internal typealias TypeErasedAssertion = (Any) -> Void

internal func eraseType<V>(_ preassertion: @escaping PreAssertion<V>) -> TypeErasedPreAssertion {
    return { (scheduler: TestScheduler, _ maxTime: Int) in
        return preassertion(scheduler, maxTime) as Any
    }
}

internal func eraseType<V>(_ assertion: @escaping Assertion<V>) -> TypeErasedAssertion {
    return { (v: Any) in
        assertion(v as! V)
    }
}

public extension SensorTestCase {

    func assert<V>(preassertion: @escaping PreAssertion<V>, assertion: @escaping Assertion<V>) -> TestMethod {
        return TestMethod().assert(preassertion: preassertion, assertion: assertion)
    }

    func assert<O>(_ subject: O,
                          isEqualTo definition: (timeline: String, values: [String: O.Element]),
                          file: StaticString = #file,
                          line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return TestMethod().assert(subject, isEqualTo: definition, file: file, line: line)
    }

    func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String: O.Element], requirements: [Int: String]),
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return TestMethod().assert(subject, isEqualTo: definition, file: file, line: line)
    }

    func assert<O>(_ observable: O,
                   isEqualToTimeline expectedTimeline: String,
                   withValues values: [String: O.Element],
                   andRequirements requirements: [Int: String] = [:],
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return TestMethod().assert(observable, isEqualToTimeline: expectedTimeline, withValues: values, andRequirements: requirements, file: file, line: line)
    }
}

/// A helper class to easily record test observables and assert their events against a marble string and values.
///
/// This class keeps all the assertions we define. Once the instance is deallocated, it starts the scheduler,
/// and asserts that the recorded outputs are correct.
///
/// This class is extended with all the methods you can use to make assertions. You don't have to instantiate this class
/// directly, use `withScheduler(testScheduler)`instead.
///
/// Usage:
/// ```
/// withScheduler(testScheduler)
///     .assert(observable1, isEqualToTimeline: "-x---", withValues: ["x": 1])
///     .assert(observable2, isEqualToTimeline: "--x--", withValues: ["x": 2])
///     .assert(observable3, isEqualToTimeline: "---x-", withValues: ["x": 3])
///     .assert {
///          // custom assertion
///     }
/// ```
public struct TestMethod {
    let assertions: [(TypeErasedPreAssertion, TypeErasedAssertion)]

    fileprivate func append<V>(preassertion: @escaping PreAssertion<V>, assertion: @escaping Assertion<V>) -> TestMethod {
        return TestMethod([(eraseType(preassertion), eraseType(assertion))])
    }

    init() {
        self.assertions = []
    }

    private init(_ assertions: [(TypeErasedPreAssertion, TypeErasedAssertion)]) {
        self.assertions = assertions
    }
}

public extension TestMethod {

    func withScheduler(_ scheduler: TestScheduler, testUntil maxTime: TestTime = 100) {
        let valuesAndAssertions = zip(assertions.map { $0.0(scheduler, maxTime) }, assertions.map { $0.1 })
        scheduler.start()
        valuesAndAssertions.forEach { $0.1($0.0) }
    }

    func assert<V>(preassertion: @escaping PreAssertion<V>, assertion: @escaping Assertion<V>) -> TestMethod {
        return append(preassertion: preassertion, assertion: assertion)
    }

    /// Records an observable an check the recorded events are the expected ones.
    ///
    /// - Parameters:
    ///   - subject: An observable whose events will be recorded and checked against an expected timeline.
    ///   - timeline: A string where each character represents an event, and its position its time. See TestScheduler.parseEventsAndTimes(...)
    ///   - values: A dictionary mapping each character in the timeline to its expected value.
    ///   - ignoreTiming: If true, the assertion succeeds if the events are equal to the expected ones in the correct order, ignoring their specific timing.
    ///                   If false, a correct sequence of events with wrong timing will fail the assertion.
    /// - Returns: The TestMethod instance where this method was called, so more assertions can be chained.


    func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String: O.Element]),
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return assert(subject, isEqualToTimeline: definition.timeline, withValues: definition.values, file: file, line: line)
    }

    func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String: O.Element], requirements: [Int: String]),
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return assert(subject, isEqualToTimeline: definition.timeline, withValues: definition.values, andRequirements: definition.requirements, file: file, line: line)
    }

    func assert<O>(_ observable: O,
                   isEqualToTimeline expectedTimeline: String,
                   withValues values: [String: O.Element],
                   andRequirements requirements: [Int: String] = [:],
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {

        return append(preassertion: { (scheduler, maxTime) in
            return TestMethod.parseAndRecord(observable, expectedTimeline: expectedTimeline, values: values, scheduler: scheduler, maxTime: maxTime)
        }, assertion: { expectedStates, recordedStates in
            let failures = TestMethod.checkFailures(expectedStates: expectedStates, recordedStates: recordedStates, expectedTimeline: expectedTimeline, values: values)
            if failures.count > 0 {
                XCTFail(failures.joined(separator: "\n"), file: file, line: line)
            }
        })
    }

    // MARK: - Private

    internal static func parseAndRecord<O>(_ observable: O, expectedTimeline: String, values: [String: O.Element], scheduler: TestScheduler, maxTime: Int) -> (expectedStates: [Recorded<Event<O.Element>>], recordedStates:  TestableObserver<O.Element>)
        where O: ObservableConvertibleType {

            let expectedStates = scheduler.parseEventsAndTimes(timeline: expectedTimeline, values: values)
            let recordedStates = scheduler.record(source: observable.asObservable(), until: max(maxTime, TestMethod.findMaxTime(in: expectedStates)))

            return (
                expectedStates: expectedStates,
                recordedStates: recordedStates
            )
    }

    internal static func checkFailures<Element>(expectedStates: [Recorded<Event<Element>>],
                                         recordedStates: TestableObserver<Element>,
                                         expectedTimeline: String,
                                         values: [String: Element],
                                         requirements: [Int: String] = [:],
                                         file: StaticString = #file,
                                         line: UInt = #line) -> [String] where Element: Equatable {

        var recordedValues = [Int: [String]]()
        var failures = [String]()

        for (index, event) in recordedStates.events.enumerated() {
            let time = event.time
            if recordedValues[time] == nil { recordedValues[time] = [] }
            if let element = event.value.element, let key = values.key(for: element) {
                recordedValues[time]?.append(key)
            } else {
                if let expected = expectedStates[index].value.element,
                    let value = event.value.element {
                    let differences  = TestMethod.diff(lhs: value, rhs: expected)
                    differences.forEach { diff in
                        var failure: String
                        switch diff {
                        case .subElementDifference(let label, let lhs, let rhs):
                            failure = "Expected \(label) to be \(rhs) at \(time), but got \(lhs)."
                        case .selfDifference:
                            failure = "Expected \(expected) at \(time), but got \(value)."
                        }
                        if let requirement = requirements[time] {
                            failure.append(" " + requirement)
                        }
                        failures.append(failure)
                    }
                }
                recordedValues[time]?.append("¿")
            }
        }

        let recordedString = TestMethod.string(from: recordedValues, maxTime: TestMethod.findMaxTime(in: recordedStates.events))

        if recordedString != expectedTimeline {
            failures = ["\(recordedString) is not equal to \(expectedTimeline)"] + failures
        }

        return failures
    }
    
    private static func findMaxTime<T>(in events: [Recorded<Event<T>>]) -> Int {
        return events.map { $0.time as Int }.max() ?? 0
    }
    
    private static func string(from eventsArray: [Int: [String]], maxTime: Int) -> String {
        return [String](repeating: "-", count: maxTime+1).enumerated().map { (index, dash) in
            if let elements = eventsArray[index] {
                return elements.count == 1 ? elements.first! : "(\(elements.joined()))"
            }
            return dash
        }.joined()
    }
    
    private enum Difference {
        case subElementDifference(label: String, lhs: Any, rhs: Any)
        // Indicates that the compared elements
        case selfDifference
    }

    // TODO: Test when diffed types are arrays, which can have different number of children?
    private static func diff<T: Equatable>(lhs: T, rhs: T) -> [Difference] {
        // TODO: check out swift dump implementation:
        // https://github.com/apple/swift/blob/master/stdlib/public/core/Dump.swift
        let valuesArray = [lhs, rhs].compactMap { Mirror(reflecting: $0).children.filter { $0.label != nil }.map { $0.value } }
        let labels = Mirror(reflecting: lhs).children.filter { $0.label != nil }.map { $0.label! }
        let values = zip(valuesArray.first!, valuesArray.last!)

        if Array(values).count > 0 {
            return zip(labels, values).compactMap { label, values in
                let leftDescription = (values.0 as AnyObject).description
                let rightDescription = (values.1 as AnyObject).description
                return !(leftDescription?.isEqual(rightDescription) ?? false) ? .subElementDifference(label: label, lhs: values.0, rhs: values.1) : nil
            }
        } else {
            return [.selfDifference]
        }
    }
}
