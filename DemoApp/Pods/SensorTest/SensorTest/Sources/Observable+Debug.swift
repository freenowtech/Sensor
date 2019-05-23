//
//  Observable+Debug.swift
//  SensorTest
//
//  Created by Ferran Pujol Camins on 10/12/2018.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import RxSwift
import RxTest
import RxCocoa

public extension ObservableType {

    /// Prints the events of an observable (much like .debug()) along with the time they occurred
    /// as measured by a test scheduler.
    ///
    /// - Parameters:
    ///   - identifier: Identifier that is printed together with event description to standard output.
    ///   - scheduler: The test scheduler that is used to determine the time of the events.
    /// - Returns: An observable sequence whose events are printed to standard output.
    func debugTest(_ identifier: String = "", scheduler: TestScheduler) -> Observable<Element> {
        return self.do(
            onNext: { (value) in
                print("\(identifier) -> Event next(\(value)) @ \(scheduler.clock)")
        },
            onError: { (error) in
                print("\(identifier) -> Event error(\(error)) @ \(scheduler.clock)")
        },
            onCompleted: {
                print("\(identifier) -> Event completed @ \(scheduler.clock)")
        },
            onSubscribed: {
                print("\(identifier) -> subscribed @ \(scheduler.clock)")
        },
            onDispose: {
                print("\(identifier) -> disposed @ \(scheduler.clock)")
        })
    }
}

public extension PrimitiveSequenceType where Trait == SingleTrait {

    /// Prints the events of a single (much like .debug()) along with the time they occurred
    /// as measured by a test scheduler.
    ///
    /// - Parameters:
    ///   - identifier: Identifier that is printed together with event description to standard output.
    ///   - scheduler: The test scheduler that is used to determine the time of the events.
    /// - Returns: A single sequence whose events are printed to standard output.
    func debugTest(_ identifier: String = "", scheduler: TestScheduler) -> Single<Element> {
        return self.do(
            onSuccess: { (value) in
                print("\(identifier) -> Event next(\(value)) @ \(scheduler.clock)")
        },
            onError: { (error) in
                print("\(identifier) -> Event error(\(error)) @ \(scheduler.clock)")
        },
            onSubscribed: {
                print("\(identifier) -> subscribed @ \(scheduler.clock)")
        },
            onDispose: {
                print("\(identifier) -> disposed @ \(scheduler.clock)")
        })
    }
}

extension SharedSequence {

    /// Prints the events of a driver (much like .debug()) along with the time they occurred
    /// as measured by a test scheduler.
    ///
    /// - Parameters:
    ///   - identifier: Identifier that is printed together with event description to standard output.
    ///   - scheduler: The test scheduler that is used to determine the time of the events.
    /// - Returns: A Driver sequence whose events are printed to standard output.
    public func debugTest(_ identifier: String = "", scheduler: TestScheduler) -> SharedSequence {
        return self.do(
            onNext: { (value) in
                print("\(identifier) -> value: \(value) @ \(scheduler.clock)")
        },
            onCompleted: {
                print("\(identifier) -> completed @ \(scheduler.clock)")
        },
            onSubscribed: {
                print("\(identifier) -> subscribed @ \(scheduler.clock)")
        },
            onDispose: {
                print("\(identifier) -> disposed @ \(scheduler.clock)")
        })
    }
}
