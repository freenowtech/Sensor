//
//  TestScheduler+MarbleTests.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxTest
import RxCocoa

public extension TestScheduler {
    /**
     Transformation from this format:
     ---a---b------c-----
     to this format
     schedule onNext(1) @ 0.6s
     schedule onNext(2) @ 1.4s
     schedule onNext(3) @ 7.0s
     ....
     ]
     You can also specify retry data in this format:
     ---a---b------c----#|----a--#|----b
     - letters and digits mark values
     - `#` marks unknown error
     - `|` marks sequence completed
     */
    func parseEventsAndTimes<T>(timeline: String, values: [String: T], errors: [String: Swift.Error] = [:]) -> [Recorded<Event<T>>] {
        //print("parsing: \(timeline)")
        typealias RecordedEvent = Recorded<Event<T>>
        var events = [Recorded<Event<T>>]()

        let timelineArray = Array(timeline).map { String($0) }

        let segments = timelineArray.reduce([String]()) { (state, current) in
            if let last = state.last, last.hasPrefix("("), !last.hasSuffix(")") {
                var state = state
                state[state.count-1] = last + current
                return state
            }
            return state + [current]
        }

        for (indexOfSegment, event) in segments.enumerated() {
            if event == "-" {
                continue
            }

            if event == "#" {
                let errorEvent = RecordedEvent(time: indexOfSegment, value: Event<T>.error(NSError(domain: "Any error domain", code: -1, userInfo: nil)))
                events.append(errorEvent)
                continue
            }

            if event == "|" {
                let completed = RecordedEvent(time: indexOfSegment, value: Event<T>.completed)
                events.append(completed)
                continue
            }

            if event.index(of: "(") == event.startIndex && event.index(of: ")") == event.index(event.endIndex, offsetBy: -1) {
                for i in event.indices[event.startIndex..<event.endIndex] {
                    let sameTimeEvent = String(event[i])
                    if sameTimeEvent == "(" || sameTimeEvent == ")" {
                        continue
                    }

                    if sameTimeEvent == "#" {
                        let errorEvent = RecordedEvent(time: indexOfSegment, value: Event<T>.error(NSError(domain: "Any error domain", code: -1, userInfo: nil)))
                        events.append(errorEvent)
                        continue
                    }

                    if sameTimeEvent == "|" {
                        let completed = RecordedEvent(time: indexOfSegment, value: Event<T>.completed)
                        events.append(completed)
                        continue
                    }

                    guard let next = values[sameTimeEvent] else {
                        guard let error = errors[event] else {
                            fatalError("Value with key \(event) not registered as value:\n\(values)\nor error:\n\(errors)")
                        }

                        let nextEvent = RecordedEvent(time: indexOfSegment, value: Event<T>.error(error))
                        events.append(nextEvent)
                        continue
                    }

                    let nextEvent = RecordedEvent(time: indexOfSegment, value: Event<T>.next(next))
                    events.append(nextEvent)
                }
            } else {
                guard let next = values[event] else {
                    guard let error = errors[event] else {
                        fatalError("Value with key \(event) not registered as value:\n\(values)\nor error:\n\(errors)")
                    }
                    let nextEvent = RecordedEvent(time: indexOfSegment, value: Event<T>.error(error))
                    events.append(nextEvent)
                    continue
                }

                let nextEvent = RecordedEvent(time: indexOfSegment, value: Event<T>.next(next))
                events.append(nextEvent)
            }
        }

        //print("parsed: \(events)")
        return events
    }

    /**
     Builds testable observer for s specific observable sequence, binds it's results and sets up disposal.
     - parameter source: Observable sequence to observe.
     - returns: Observer that records all events for observable sequence.
     */
    func record<O: ObservableConvertibleType>(source: O, until testTime: Int = 100000) -> TestableObserver<O.E> {
        let observer = self.createObserver(O.E.self)
        let disposable = source.asObservable().bind(to: observer)
        self.scheduleAt(testTime) {
            disposable.dispose()
        }
        return observer
    }
}
