//
//  SensorTestCase.swift
//  SensorTest
//
//  Created by Ferran Pujol Camins on 05/04/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import RxSwift
import RxTest
import RxCocoa

/// Make your XCTestCase class conform to this protocol to get some handy methods to make the tests less verbose.
// TODO: conver to class
public protocol SensorTestCase: AssertionDSLProtocol {
    var scheduler: TestScheduler! { get }
}

extension SensorTestCase {
    // MARK: Hot Observable
    public func hotObservable<T>(timeline: String, values: [String: T] = [:], errors: [String: Error] = [:]) -> Observable<T> {
        return scheduler.hotObservable(timeline: timeline, values: values, errors: errors)
    }

    public func hotObservable<T>(_ definition: (timeline: String, values: [String: T])) -> Observable<T> {
        return scheduler.hotObservable(timeline: definition.timeline, values: definition.values)
    }

    public func hotObservable<T>(_ definition: (timeline: String, values: [String: T], errors: [String: Error])) -> Observable<T> {
        return scheduler.hotObservable(timeline: definition.timeline, values: definition.values, errors: definition.errors)
    }

    // MARK: Hot Single
    public func hotSingle<T>(timeline: String, values: [String: T] = [:], errors: [String: Error] = [:]) -> Single<T> {
        return scheduler.hotSingle(timeline: timeline, values: values, errors: errors)
    }

    public func hotSingle<T>(_ definition: (timeline: String, values: [String: T])) -> Single<T> {
        return scheduler.hotSingle(timeline: definition.timeline, values: definition.values)
    }

    public func hotSingle<T>(_ definition: (timeline: String, values: [String: T], errors: [String: Error])) -> Single<T> {
        return scheduler.hotSingle(timeline: definition.timeline, values: definition.values, errors: definition.errors)
    }

    // MARK: Hot Signal
    public func hotSignal<T>(timeline: String, values: [String: T] = [:], errors: [String: Error] = [:]) -> Signal<T> {
        return scheduler.hotSignal(timeline: timeline, values: values, errors: errors)
    }

    public func hotSignal<T>(_ definition: (timeline: String, values: [String: T])) -> Signal<T> {
        return scheduler.hotSignal(timeline: definition.timeline, values: definition.values)
    }

    public func hotSignal<T>(_ definition: (timeline: String, values: [String: T], errors: [String: Error])) -> Signal<T> {
        return scheduler.hotSignal(timeline: definition.timeline, values: definition.values, errors: definition.errors)
    }

    // MARK: Cold Observable
    public func coldObservable<T>(timeline: String, values: [String: T] = [:], errors: [String: Error] = [:]) -> Observable<T> {
        return scheduler.hotObservable(timeline: timeline, values: values, errors: errors)
    }

    public func coldObservable<T>(_ definition: (timeline: String, values: [String: T])) -> Observable<T> {
        return scheduler.hotObservable(timeline: definition.timeline, values: definition.values)
    }

    public func coldObservable<T>(_ definition: (timeline: String, values: [String: T], errors: [String: Error])) -> Observable<T> {
        return scheduler.hotObservable(timeline: definition.timeline, values: definition.values, errors: definition.errors)
    }

    // MARK: Cold Single
    public func coldSingle<T>(timeline: String, values: [String: T] = [:], errors: [String: Error] = [:]) -> Single<T> {
        return scheduler.coldSingle(timeline: timeline, values: values, errors: errors)
    }

    public func coldSingle<T>(_ definition: (timeline: String, values: [String: T])) -> Single<T> {
        return scheduler.coldSingle(timeline: definition.timeline, values: definition.values)
    }

    public func coldSingle<T>(_ definition: (timeline: String, values: [String: T], errors: [String: Error])) -> Single<T> {
        return scheduler.coldSingle(timeline: definition.timeline, values: definition.values, errors: definition.errors)
    }

    // MARK: Cold Signal
    public func coldSignal<T>(timeline: String, values: [String: T] = [:], errors: [String: Error] = [:]) -> Signal<T> {
        return scheduler.coldSignal(timeline: timeline, values: values, errors: errors)
    }

    public func coldSignal<T>(_ definition: (timeline: String, values: [String: T])) -> Signal<T> {
        return scheduler.coldSignal(timeline: definition.timeline, values: definition.values)
    }

    public func coldSignal<T>(_ definition: (timeline: String, values: [String: T], errors: [String: Error])) -> Signal<T> {
        return scheduler.coldSignal(timeline: definition.timeline, values: definition.values, errors: definition.errors)
    }
}

extension TestScheduler {
    // MARK: Hot Observable
    public func hotObservable<T>(timeline: String, values: [String: T] = [:], errors: [String: Error] = [:]) -> Observable<T> {
        return createHotObservable(parseEventsAndTimes(timeline: timeline, values: values, errors:  errors)).asObservable()
    }

    // MARK: Hot Single
    public func hotSingle<T>(timeline: String, values: [String: T] = [:], errors: [String: Error] = [:]) -> Single<T> {
        return createHotObservable(parseEventsAndTimes(timeline: timeline, values: values, errors:  errors)).take(1).asSingle()
    }

    // MARK: Hot Signal
    public func hotSignal<T>(timeline: String, values: [String: T] = [:], errors: [String: Error] = [:]) -> Signal<T> {
        return createHotObservable(parseEventsAndTimes(timeline: timeline, values: values, errors:  errors)).asSignal(onErrorSignalWith: Signal.never())
    }

    // MARK: Cold Observable
    public func coldObservable<T>(timeline: String, values: [String: T] = [:], errors: [String: Error] = [:]) -> Observable<T> {
        return createColdObservable(parseEventsAndTimes(timeline: timeline, values: values, errors:  errors)).asObservable()
    }

    // MARK: Cold Single
    public func coldSingle<T>(timeline: String, values: [String: T] = [:], errors: [String: Error] = [:]) -> Single<T> {
        return createColdObservable(parseEventsAndTimes(timeline: timeline, values: values, errors:  errors)).take(1).asSingle()
    }

    // MARK: Cold Signal
    public func coldSignal<T>(timeline: String, values: [String: T] = [:], errors: [String: Error] = [:]) -> Signal<T> {
        return createColdObservable(parseEventsAndTimes(timeline: timeline, values: values, errors:  errors)).asSignal(onErrorSignalWith: Signal.never())
    }
}
