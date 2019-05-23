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
public protocol SensorTestCase {
    var scheduler: TestScheduler! { get }
}

extension SensorTestCase {
    public func hotObservable<T>(timeline: String, values: [String: T]) -> Observable<T> {
        return scheduler.hotObservable(timeline: timeline, values: values)
    }

    public func hotObservable<T>(_ definition: (timeline: String, values: [String: T])) -> Observable<T> {
        return scheduler.hotObservable(timeline: definition.timeline, values: definition.values)
    }

    public func hotSingle<T>(timeline: String, values: [String: T]) -> Single<T> {
        return scheduler.hotSingle(timeline: timeline, values: values)
    }

    public func hotSingle<T>(_ definition: (timeline: String, values: [String: T])) -> Single<T> {
        return scheduler.hotSingle(timeline: definition.timeline, values: definition.values)
    }

    public func hotSignal<T>(timeline: String, values: [String: T]) -> Signal<T> {
        return scheduler.hotSignal(timeline: timeline, values: values)
    }

    public func hotSignal<T>(_ definition: (timeline: String, values: [String: T])) -> Signal<T> {
        return scheduler.hotSignal(timeline: definition.timeline, values: definition.values)
    }

    public func coldObservable<T>(timeline: String, values: [String: T]) -> Observable<T> {
        return scheduler.hotObservable(timeline: timeline, values: values)
    }

    public func coldObservable<T>(_ definition: (timeline: String, values: [String: T])) -> Observable<T> {
        return scheduler.hotObservable(timeline: definition.timeline, values: definition.values)
    }

    public func coldSingle<T>(timeline: String, values: [String: T]) -> Single<T> {
        return scheduler.coldSingle(timeline: timeline, values: values)
    }

    public func coldSingle<T>(_ definition: (timeline: String, values: [String: T])) -> Single<T> {
        return scheduler.coldSingle(timeline: definition.timeline, values: definition.values)
    }

    public func coldSignal<T>(timeline: String, values: [String: T]) -> Signal<T> {
        return scheduler.coldSignal(timeline: timeline, values: values)
    }

    public func coldSignal<T>(_ definition: (timeline: String, values: [String: T])) -> Signal<T> {
        return scheduler.coldSignal(timeline: definition.timeline, values: definition.values)
    }
}

extension TestScheduler {
    public func hotObservable<T>(timeline: String, values: [String: T]) -> Observable<T> {
        return createHotObservable(parseEventsAndTimes(timeline: timeline, values: values)).asObservable()
    }

    public func hotSingle<T>(timeline: String, values: [String: T]) -> Single<T> {
        return createHotObservable(parseEventsAndTimes(timeline: timeline, values: values)).take(1).asSingle()
    }

    public func hotSignal<T>(timeline: String, values: [String: T]) -> Signal<T> {
        return createHotObservable(parseEventsAndTimes(timeline: timeline, values: values)).asSignal(onErrorSignalWith: Signal.never())
    }

    public func coldObservable<T>(timeline: String, values: [String: T]) -> Observable<T> {
        return createColdObservable(parseEventsAndTimes(timeline: timeline, values: values)).asObservable()
    }

    public func coldSingle<T>(timeline: String, values: [String: T]) -> Single<T> {
        return createColdObservable(parseEventsAndTimes(timeline: timeline, values: values)).take(1).asSingle()
    }

    public func coldSignal<T>(timeline: String, values: [String: T]) -> Signal<T> {
        return createColdObservable(parseEventsAndTimes(timeline: timeline, values: values)).asSignal(onErrorSignalWith: Signal.never())
    }
}
