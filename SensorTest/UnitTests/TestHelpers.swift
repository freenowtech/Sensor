//
//  TestHelpers.swift
//  SensorTestUnitTests
//
//  Created by Ferran Pujol Camins on 31/05/2019.
//

import Foundation
@testable import SensorTest
import RxSwift
import RxTest

extension SensorTestCase {

    func toRecorded<E>(_ timelineDict: [Int: [Event<E>]]) -> [Int: [Recorded<Event<E>>]] {
        var d = [Int: [Recorded<Event<E>>]]()
        for a in timelineDict {
            d[a.key] = a.value.map { Recorded(time: a.key, value: $0) }
        }
        return d
    }

    func failures<V: Equatable>(forExpectedTimeline expectedTimeline: String, given inputTimeline: String, withValues values: [String: V], andErrors errors: [String: Error] = [:], expectations: Expectations) -> [String] {
        return failures(
            forExpectedTimeline: expectedTimeline,
            withValues: values,
            andExpectedErrors: errors,
            given: inputTimeline,
            withValues: values,
            andInputErrors: errors,
            expectations: expectations
        )
    }

    func failures<V>(
        forExpectedTimeline expectedTimeline: String,
        withValues expectedValues: [String: V],
        andExpectedErrors expectedErrors: [String: Error] = [:],
        given inputTimeline: String,
        withValues inputValues: [String: V],
        andInputErrors inputErrors: [String: Error] = [:],
        expectations: Expectations)
        -> [String] where V: Equatable {

            let observable = hotObservable(timeline: inputTimeline, values: inputValues, errors: inputErrors)
            let (expectedStates, recordedStates) = TestMethod.parseAndRecord(
                observable,
                expectedTimeline: expectedTimeline,
                values: expectedValues,
                errors: expectedErrors,
                scheduler: scheduler,
                maxTime: Int.max
            )
            scheduler.start()
            return TestMethod.checkFailures(
                expectedStates: expectedStates,
                recordedStates: recordedStates,
                expectedTimeline: expectedTimeline,
                values: expectedValues,
                errors: expectedErrors,
                expectations: expectations
            )
    }
}
