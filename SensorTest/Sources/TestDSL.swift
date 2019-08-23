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
public typealias Expectations = [String: [Int]]

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

extension SensorTestCase {

    public func assert<V>(preassertion: @escaping PreAssertion<V>, assertion: @escaping Assertion<V>) -> TestMethod {
        return TestMethod(scheduler: scheduler).assert(preassertion: preassertion, assertion: assertion)
    }

    public func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String: O.Element]),
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return TestMethod(scheduler: scheduler).assert(subject, isEqualTo: definition, file: file, line: line)
    }

    public func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String: O.Element], errors: [String: Error]),
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return TestMethod(scheduler: scheduler).assert(subject, isEqualTo: definition, file: file, line: line)
    }

    public func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String: O.Element], expectations: Expectations),
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return TestMethod(scheduler: scheduler).assert(subject, isEqualTo: definition, file: file, line: line)
    }

    public func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String: O.Element], errors: [String: Error], expectations: Expectations),
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return TestMethod(scheduler: scheduler).assert(subject, isEqualTo: definition, file: file, line: line)
    }

    public func assert<O>(_ observable: O,
                   isEqualToTimeline expectedTimeline: String,
                   withValues values: [String: O.Element],
                   errors: [String: Error],
                   andExpectations expectations: Expectations = [:],
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return TestMethod(scheduler: scheduler).assert(observable, isEqualToTimeline: expectedTimeline, withValues: values, errors: errors, andExpectations: expectations, file: file, line: line)
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
///   assert(observable1, isEqualToTimeline: "-x---", withValues: ["x": 1])
///     .assert(observable2, isEqualToTimeline: "--x--", withValues: ["x": 2])
///     .assert(observable3, isEqualToTimeline: "---x-", withValues: ["x": 3])
///     .assert {
///          // custom assertion
///     }
///     .withScheduler(testScheduler)
/// ```
public struct TestMethod {
    let assertions: [(TypeErasedPreAssertion, TypeErasedAssertion)]
    let scheduler: TestScheduler

    fileprivate func append<V>(preassertion: @escaping PreAssertion<V>, assertion: @escaping Assertion<V>) -> TestMethod {
        return TestMethod(scheduler: scheduler, assertions: assertions + [(eraseType(preassertion), eraseType(assertion))])
    }

    init(scheduler: TestScheduler) {
        self.assertions = []
        self.scheduler = scheduler
    }

    private init(scheduler: TestScheduler, assertions: [(TypeErasedPreAssertion, TypeErasedAssertion)]) {
        self.assertions = assertions
        self.scheduler = scheduler
    }
}

extension TestMethod: AssertionDSLProtocol {

    public func runTest(testUntil maxTime: TestTime = 100) {
        let valuesAndAssertions = assertions.map { ($0.0(scheduler, maxTime), $0.1) }
        scheduler.start()
        valuesAndAssertions.forEach { $0.1($0.0) }
    }

    public func assert<V>(preassertion: @escaping PreAssertion<V>, assertion: @escaping Assertion<V>) -> TestMethod {
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


    public func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String: O.Element]),
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return assert(subject, isEqualToTimeline: definition.timeline, withValues: definition.values, errors: [:], file: file, line: line)
    }

    public func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String: O.Element], errors: [String: Error]),
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return assert(subject, isEqualToTimeline: definition.timeline, withValues: definition.values, errors: definition.errors, file: file, line: line)
    }

    public func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String: O.Element], expectations: Expectations),
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return assert(subject, isEqualToTimeline: definition.timeline, withValues: definition.values, errors: [:], andExpectations: definition.expectations, file: file, line: line)
    }

    public func assert<O>(_ subject: O,
                   isEqualTo definition: (timeline: String, values: [String: O.Element], errors: [String: Error], expectations: Expectations),
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return assert(subject, isEqualToTimeline: definition.timeline, withValues: definition.values, errors: definition.errors, andExpectations: definition.expectations, file: file, line: line)
    }

    public func assert<O>(_ observable: O,
                   isEqualToTimeline expectedTimeline: String,
                   withValues values: [String: O.Element],
                   errors: [String: Error],
                   andExpectations expectations: Expectations = [:],
                   file: StaticString = #file,
                   line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {

        return append(
            preassertion: { scheduler, maxTime in
                return TestMethod.parseAndRecord(
                    observable, expectedTimeline:
                    expectedTimeline,
                    values: values,
                    errors: errors,
                    scheduler: scheduler,
                    maxTime: maxTime)
            },
            assertion: { expectedStates, recordedStates in
                let failures = TestMethod.checkFailures(expectedStates: expectedStates, recordedStates: recordedStates, expectedTimeline: expectedTimeline, values: values, errors: errors)
                if failures.count > 0 {
                    XCTFail(failures.joined(separator: "\n"), file: file, line: line)
                }
        })
    }

    // MARK: - Private

    internal static func parseAndRecord<O>(
        _ observable: O,
        expectedTimeline: String,
        values: [String: O.Element],
        errors: [String: Error],
        scheduler: TestScheduler,
        maxTime: Int)
        -> (expectedStates: [Recorded<Event<O.Element>>], recordedStates:  TestableObserver<O.Element>)
        where O: ObservableConvertibleType {

            let expectedStates = scheduler.parseEventsAndTimes(timeline: expectedTimeline, values: values, errors: errors)
            let recordedStates = scheduler.record(source: observable.asObservable(), until: max(maxTime, TestMethod.findMaxTime(in: expectedStates)))

            return (
                expectedStates: expectedStates,
                recordedStates: recordedStates
            )
    }

    internal static func checkFailures<Element>(
        expectedStates: [Recorded<Event<Element>>],
        recordedStates: TestableObserver<Element>,
        expectedTimeline: String,
        values: [String: Element],
        errors: [String: Error],
        expectations: Expectations = [:],
        file: StaticString = #file,
        line: UInt = #line) -> [String] where Element: Equatable {

        // assertionTimes are the times when need to check that expectedStates and recordedStates are Equal.
        let assertionTimes = mergeAndSort(
            expectedStates.map { $0.time },
            recordedStates.events.map { $0.time }
        )

        let expectedStatesByTime = Dictionary(grouping: expectedStates) { $0.time }
        let recordedStatesByTime = Dictionary(grouping: recordedStates.events) { $0.time }

        let recordedEventsTimeline = timeline(for: recordedStatesByTime, withValues: values, andErrors: errors)

        let failureMessages: [String] = assertionTimes.flatMap { time -> [String] in
            let expectedEvents = expectedStatesByTime[time]?.map { $0.value.asCustomEquatable() } ?? []
            let recordedEvents = recordedStatesByTime[time]?.map { $0.value.asCustomEquatable() } ?? []
            let (matchedEvents, missingExpectedEvents, unexpectedRecordedEvents) = matchEqualValues(expectedEvents, recordedEvents)
            // The common events are now in the same order in the beggining of the array
            let orderedExpectedEvents = (matchedEvents + missingExpectedEvents).map { $0.value }
            let orderedRecordedEvents = (matchedEvents + unexpectedRecordedEvents).map { $0.value }

            if orderedExpectedEvents != orderedRecordedEvents {
                let differences = diff(orderedExpectedEvents, orderedRecordedEvents, values: values)
                return differences.map { $0.description(time: time) } + expectations.forTime(time)
            }
            return []
        }

        if !failureMessages.isEmpty {
            let trimmedExpectedTimeline = expectedTimeline.filter { $0 != " " }
            let simplifiedExpectedTimeline = simplifyTimeline(trimmedExpectedTimeline, eventNames: values.keys, errorNames: errors.keys)
            let simplifiedRecordedTimeline = simplifyTimeline(recordedEventsTimeline, eventNames: values.keys, errorNames: errors.keys)

            if (simplifiedExpectedTimeline != simplifiedRecordedTimeline) {
                return ["Recorded timeline '\(recordedEventsTimeline)' is not equal to expected timeline '\(trimmedExpectedTimeline)'"] + failureMessages
            } else {
                return failureMessages
            }
        }
        return []
    }

    private static func matchEqualValues<Element: Equatable>(_ lhs: [Element], _ rhs: [Element]) -> (matches: [Element], onlyLhs: [Element], onlyRhs: [Element])  {
        var matches = [Element]()
        var onlyLhs = [Element]()
        var rhs = rhs
        for element in lhs {
            if let i = rhs.firstIndex(of: element) {
                matches.append(element)
                rhs.remove(at: i)
            } else {
                onlyLhs.append(element)
            }
        }
        return (matches: matches, onlyLhs: onlyLhs, onlyRhs: rhs)
    }

    private static func mergeAndSort(_ lhs: [Int], _ rhs: [Int]) -> [Int] {
        let lhsSet = Set(lhs)
        let rhsSet = Set(rhs)
        return Array(lhsSet.union(rhsSet)).sorted(by: <)
    }
    
    private static func findMaxTime<T>(in events: [Recorded<Event<T>>]) -> Int {
        return events.map { $0.time as Int }.max() ?? 0
    }
}

fileprivate func diff<T: Equatable>(_ expected: [Event<T>], _ recorded: [Event<T>], values: [String: T]) -> [Difference] {
    if let expectedEvent = expected.first, let recordedEvent = recorded.first, expected.count == 1, recorded.count == 1 {
        switch (expectedEvent, recordedEvent) {
        case (.next(let expectedElement), .next(let recordedElement)):
            let valueLabel = values.first(where: { $0.value == expectedElement })?.key ?? "¿"
            return diff(expectedElement, recordedElement, valueLabel: valueLabel)
        default:
            break
        }
    }
    return [.arrayDifference(expected: expected, value: recorded)]
}

extension Expectations {
    func forTime(_ time: Int) -> [String] {
        return compactMap { arg in
            let (expectation, expectationTimes) = arg
            if expectationTimes.contains(time) {
                return expectation
            }
            return nil
        }
    }
}

extension Difference {
    public func description(time: Int) -> String {
        switch self {
        case .primitiveTypeDifference(let valueLabel, let expected, let recorded):
            return "Expected value '\(valueLabel)' to be '\(expected)' at time \(time), but got '\(recorded)'."
        case .singlePrimitiveChildrenDifference(let valueLabel, let childrenLabel, let expectedChildren, let children):
            return "Expected property '\(childrenLabel)' of value '\(valueLabel)' to be '\(expectedChildren)' at time \(time), but got '\(children)'."
        case .childrenDifference(let expectedLabel):
            return "value '\(expectedLabel)' is not equal to the expected value at time \(time)"
        case .arrayDifference(let expected, let value):
            return "Expected \(expected) at time \(time), but got \(value)."
        }
    }
}

// Replaces all event names with '¿' and all error names with 'x', so two timelines with the same "shape" are equal after being simplified.
fileprivate func simplifyTimeline<Element>(_ timeline: String, eventNames: Dictionary<String, Element>.Keys, errorNames: Dictionary<String, Error>.Keys) -> String {
    let eventNames = eventNames.map(Character.init)
    let errorNames = errorNames.map(Character.init)
    return timeline.map { char -> String in
        if eventNames.contains(char) {
            return "¿"
        } else if errorNames.contains(char) {
            return "x"
        } else {
            return String(char)
        }
    }.reduce("", +)
}
