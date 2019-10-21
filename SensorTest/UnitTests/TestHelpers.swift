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

    func failures<V>(forExpected expected: Definition<V>, given input: Definition<V>)-> [String] where V: Equatable {
            let observable = hotObservable(input)
            let (expectedStates, recordedStates) = TestMethod.parseAndRecord(
                observable,
                expectedTimeline: expected.timeline,
                values: expected.values,
                errors: expected.errors,
                scheduler: scheduler,
                maxTime: Int.max
            )
            scheduler.start()
            return TestMethod.checkFailures(
                expectedStates: expectedStates,
                recordedStates: recordedStates,
                expectedTimeline: expected.timeline,
                values: expected.values,
                errors: expected.errors,
                expectations: expected.expectations
            )
    }
}
