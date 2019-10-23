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
public protocol SensorTestCase {
    var scheduler: TestScheduler! { get }
}

extension SensorTestCase {
    // MARK: Hot Observables

    public func hotObservable<T>(_ definition: Definition<T>) -> Observable<T> {
        return scheduler.hotObservable(definition)
    }

    public func hotSingle<T>(_ definition: Definition<T>) -> Single<T> {
        return scheduler.hotSingle(definition)
    }

    public func hotSignal<T>(_ definition: Definition<T>) -> Signal<T> {
        return scheduler.hotSignal(definition)
    }

    public func hotTestableObservable<T>(_ definition: Definition<T>) -> TestableObservable<T> {
        return scheduler.hotTestableObservable(definition)
    }

    // MARK: Hot Observables

    public func coldObservable<T>(_ definition: Definition<T>) -> Observable<T> {
        return scheduler.hotObservable(definition)
    }

    public func coldSingle<T>(_ definition: Definition<T>) -> Single<T> {
        return scheduler.coldSingle(definition)
    }

    public func coldSignal<T>(_ definition: Definition<T>) -> Signal<T> {
        return scheduler.coldSignal(definition)
    }

    public func coldTestableObservable<T>(_ definition: Definition<T>) -> TestableObservable<T> {
        return scheduler.coldTestableObservable(definition)
    }
}

extension TestScheduler {
    // MARK: Hot Observables
    public func hotObservable<T>(_ definition: Definition<T>) -> Observable<T> {
        return hotTestableObservable(definition).asObservable()
    }

    public func hotSingle<T>(_ definition: Definition<T>) -> Single<T> {
        return hotTestableObservable(definition).take(1).asSingle()
    }

    public func hotSignal<T>(_ definition: Definition<T>) -> Signal<T> {
        return hotTestableObservable(definition).asSignal(onErrorSignalWith: Signal.never())
    }

    public func hotTestableObservable<T>(_ definition: Definition<T>) -> TestableObservable<T> {
        return coldTestableObservable(definition)
    }

    // MARK: Cold Observables
    public func coldObservable<T>(_ definition: Definition<T>) -> Observable<T> {
        return coldTestableObservable(definition).asObservable()
    }

    public func coldSingle<T>(_ definition: Definition<T>) -> Single<T> {
        return coldTestableObservable(definition).take(1).asSingle()
    }

    public func coldSignal<T>(_ definition: Definition<T>) -> Signal<T> {
        return coldTestableObservable(definition).asSignal(onErrorSignalWith: Signal.never())
    }

    public func coldTestableObservable<T>(_ definition: Definition<T>) -> TestableObservable<T> {
        return createColdObservable(parseEventsAndTimes(timeline: definition.timeline, values: definition.values, errors: definition.errors))
    }
}
