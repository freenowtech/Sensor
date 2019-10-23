//
//  RandomAssertionTests.swift
//  SensorTestUnitTests
//
//  Created by Ferran Pujol Camins on 16/05/2019.
//

import XCTest
@testable import SensorTest
import RxSwift
import RxTest
import SnapshotTesting

class RandomAssertionTests: XCTestCase, SensorTestCase {

    var scheduler: TestScheduler!

    func testRandomTimeline() {
        var i = 0
        var failures = [String]()
        repeat {
            scheduler = TestScheduler(initialClock: 0, resolution: 1, simulateProcessingDelay: false)
            let values = [
                "a": "a", "b": "b", "c": "c"
            ]
            let timelineDict = generateTimeline(
                forValues: Array(values.values),
                maxLength: 15,
                maxElementsPerTime: 4
            )

            let timelineString = timeline(for: toRecorded(timelineDict), withValues: values, andErrors: [:])

            print("timeline: \(timelineString)")
            print("values: \(values)")

            failures = self.failures(forExpected: Definition(timeline: timelineString, values: values), given: Definition(timeline: timelineString, values: values))

            if failures.isEmpty {
                print("ok\n")
            } else {
                print("failures:")
                print(failures.joined(separator: "\n"))
                print("\n")
            }
            XCTAssertEqual(failures, [])
            i += 1
        } while failures.isEmpty && i < 1000
    }

    func generateTimeline<T>(forValues values: [T], maxLength: Int, maxElementsPerTime: Int) -> [Int: [Event<T>]] {
        let length = Int.random(in: 1...maxLength)
        let timeline = (0..<length-1).compactMap { time -> (Int, [Event<T>])? in
            if Bool.random() {
                return (time, randomElements(forValues: values, maxElements: maxElementsPerTime))
            } else {
                return nil
            }
        }
        let lastEvent: [Event<T>] = [
            [],
            [.error(NSError(domain: "ERROR", code: 666, userInfo: nil))],
            [.completed]
        ].randomElement()!
        return Dictionary(uniqueKeysWithValues: timeline + [(length - 1, lastEvent)])
    }

    func randomElements<T>(forValues values: [T], maxElements: Int) -> [Event<T>] {
        let severalElements = maxElements > 1 ? Bool.random() : false
        let numberOfElements = severalElements ? Int.random(in: 2...maxElements) : 1
        let elements = (0..<numberOfElements).map { _ in values.randomElement()! }
        return elements.map { .next($0) }
    }
}
