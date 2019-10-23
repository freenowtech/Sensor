//
//  TimelineTests.swift
//  SensorTestUnitTests
//
//  Created by Ferran Pujol Camins on 16/05/2019.
//

import XCTest
import RxTest
@testable import SensorTest

class TimelineTests: XCTestCase {
    let scheduler = TestScheduler(initialClock: 0, resolution: 1, simulateProcessingDelay: false)

    func testEmptyTimeline() {
        let inputTimeline = "---"
        let values = [String: Int]()
        let events = scheduler.parseEventsAndTimes(timeline: inputTimeline, values: values)
        let groupedEvents = Dictionary(grouping: events) { $0.time }
        XCTAssertEqual(
            timeline(for: groupedEvents, withValues: values, andErrors: [:]),
            "-"
        )
    }

    func testValues() {
        executeTest(inputTimeline: "-t-f", values: ["t": true, "f": false])
    }

    func testValuesAtSameTime() {
        executeTest(inputTimeline: "-(tf)-", values: ["t": true, "f": false])
    }

    func testCompleted() {
        executeTest(inputTimeline: "-|-", values: ["t": true, "f": false])
    }

    func testUnkownError() {
        executeTest(inputTimeline: "-#-", values: ["t": true, "f": false])
    }

    func testError() {
        executeTest(inputTimeline: "-x-", values: [String: Bool](), errors: ["x": NSError(domain: "error", code: 6, userInfo: nil)])
    }

    func testValuesAtSameTimeWithCompletion() {
        executeTest(inputTimeline: "-(tf|)-", values: ["t": true, "f": false])
    }

    func executeTest<Element: Equatable>(
        inputTimeline: String,
        values: [String: Element],
        errors: [String: Error] = [:],
        file: StaticString = #file,
        line: UInt = #line) {

        let events = scheduler.parseEventsAndTimes(timeline: inputTimeline, values: values, errors: errors)
        let groupedEvents = Dictionary(grouping: events) { $0.time }
        XCTAssertEqual(
            timeline(for: groupedEvents, withValues: values, andErrors: errors),
            inputTimeline.trimmingTrailing("-"),
            file: file,
            line: line
        )
    }
}

private extension String {
    func trimmingTrailing(_ c: Character) -> String {
        if let i = lastIndex(where: { $0 != c }) {
            return String(self[startIndex...i])
        }
        return ""
    }
}
