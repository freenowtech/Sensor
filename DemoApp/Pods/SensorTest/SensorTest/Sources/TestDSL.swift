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
public class TestMethod {
    let scheduler: TestScheduler
    var maxTime: Int
    var assertions: [() -> Void] = []

    fileprivate func appendAssertion(_ assertion: @escaping () -> Void) {
        assertions += [assertion]
    }

    public init(scheduler: TestScheduler, testUntil: TestTime) {
        self.scheduler = scheduler
        self.maxTime = testUntil
    }

    deinit {
        scheduler.start()
        assertions.forEach { $0() }
    }
}

public func withScheduler(_ scheduler: TestScheduler, testUntil: TestTime = 100) -> TestMethod {
    return TestMethod(scheduler: scheduler, testUntil: testUntil)
}

public extension TestMethod {
    @discardableResult
    func assert(_ assertion: @escaping () -> Void) -> TestMethod {
        appendAssertion(assertion)
        return self
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
    @discardableResult
    func assert<O>(_ subject: O,
                          isEqualToTimeline timeline: String,
                          withValues values: [String: O.Element],
                          file: StaticString = #file,
                          line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {

        let recorded = scheduler.record(source: subject)
        let expectedTimeline = scheduler.parseEventsAndTimes(timeline: timeline, values: values)

        appendAssertion { [recorded, expectedTimeline] in
            XCTAssertEqual(recorded.events, expectedTimeline, file: file, line: line)
        }
        return self
    }

    @discardableResult
    func assert<O>(_ subject: O,
                          isEqualTo definition: (timeline: String, values: [String: O.Element]),
                          file: StaticString = #file,
                          line: UInt = #line) -> TestMethod where O: ObservableConvertibleType, O.Element: Equatable {
        return assert(subject, isEqualToTimeline: definition.timeline, withValues: definition.values, file: file, line: line)
    }
    
    @discardableResult
    func assert<T: ObservableConvertibleType>(sequence: T,
                                                     expectation: String,
                                                     definitions: [String: T.Element],
                                                     file: StaticString = #file,
                                                     line: UInt = #line) -> TestMethod where T.Element: Equatable {
        
        
        let expectedStates = scheduler.parseEventsAndTimes(timeline: expectation, values: definitions)
        let recordedStates = scheduler.record(source: sequence.asObservable().debug("sequence"), until: max(maxTime, TestMethod.findMaxTime(in: expectedStates)))
        
        appendAssertion {
            var recordedValues = [String: [String]]()
            var failures = [String]()
            
            for (index, event) in recordedStates.events.enumerated() {
                let time = event.time
                let timeString = String(time)
                if recordedValues[timeString] == nil { recordedValues[String(time)] = [] }
                if let element = event.value.element, let key = definitions.key(for: element) {
                    recordedValues[timeString]?.append(key)
                } else {
                    if let expected = expectedStates[index].value.element,
                        let event = event.value.element {
                        let differences  = TestMethod.diff(lhs: event, rhs: expected)
                        differences.forEach { diff in
                            failures.append("Expected \(diff.label) to be \(diff.rhs) at \(time), but got \(diff.lhs).")
                        }
                    }
                    recordedValues[timeString]?.append("¿")
                }
            }
            
            let recordedString = TestMethod.string(from: recordedValues, maxTime: TestMethod.findMaxTime(in: recordedStates.events))
            
            if recordedString != expectation {
                failures = ["\(recordedString) is not equal to \(expectation)"] + failures
            }
            
            if failures.count > 0 {
                XCTFail(failures.joined(separator: "\n"), file: file, line: line)
            }
        }
        
        return self
    }
    
    
    
    private static func findMaxTime<T>(in events: [Recorded<Event<T>>]) -> Int {
        return events.map { $0.time as Int }.max() ?? 0
    }
    
    private static func string(from eventsArray: [String: [String]], maxTime: Int) -> String {
        return [String](repeating: "-", count: maxTime+1).enumerated().map { (index, dash) in
            if let elements = eventsArray[String(index)] {
                return elements.count == 1 ? elements.first! : "(\(elements.joined()))"
            }
            return dash
            }.joined()
    }
    
    private struct Difference {
        let label: String
        let lhs: Any
        let rhs: Any
    }
    
    private static func diff<T: Equatable>(lhs: T, rhs: T) -> [Difference] {
        let valuesArray = [lhs, rhs].compactMap { Mirror(reflecting: $0).children.filter { $0.label != nil }.map { $0.value } }
        let labels = Mirror(reflecting: lhs).children.filter { $0.label != nil }.map { $0.label! }
        let values = zip(valuesArray.first!, valuesArray.last!)
        
        return zip(labels, values).compactMap { label, values in
            let leftDescription = (values.0 as AnyObject).description
            let rightDescription = (values.1 as AnyObject).description
            return !(leftDescription?.isEqual(rightDescription) ?? false) ? Difference(label: label, lhs: values.0, rhs: values.1) : nil
        }
    }
}
