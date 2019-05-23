//
//  TestScheduler+MarbleTests.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/29/15.

//  The MIT License Copyright © 2015 Krunoslav Zaher All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Modified work Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length

import RxSwift
import RxTest
import RxCocoa
import XCTest

extension Dictionary where Key == String, Value: Equatable {
    func key(for value: Value) -> Key? {
        return compactMap { value == $1 ? $0 : nil }.first
    }
}

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
     
     You can add whitespaces to the timeline. They are ignored. It might be helpful to align several timelines
     or group long timelines and annotate the virtual time. Like this:
     '----a-----a----'
     '     b--c      '
     '           b--c'
     
     '0123456789 0123456789'
     '-----a---- -----b---c'

     You can express that two events happen at the same time by surrounding them with parentheses:
     '012345   6789'
     '-----(ab)----'
     */
    func parseEventsAndTimes<T>(timeline: String, values: [String: T], errors: [String: Swift.Error] = [:]) -> [Recorded<Event<T>>] {
        typealias RecordedEvent = Recorded<Event<T>>
        var events = [Recorded<Event<T>>]()
        
        let timelineArray = Array(timeline).map { String($0) }.filter { $0 != " " }
        
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
            
            if event.firstIndex(of: "(") == event.startIndex && event.firstIndex(of: ")") == event.index(event.endIndex, offsetBy: -1) {
                for index in event.indices[event.startIndex..<event.endIndex] {
                    let sameTimeEvent = String(event[index])
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

        return events
    }
    
    /**
     Builds testable observer for s specific observable sequence, binds it's results and sets up disposal.
     - parameter source: Observable sequence to observe.
     - returns: Observer that records all events for observable sequence.
     */
    func record<O: ObservableConvertibleType>(source: O, until testTime: Int = 100000) -> TestableObserver<O.Element> {
        let observer = self.createObserver(O.Element.self)
        let disposable = source.asObservable().bind(to: observer)
        self.scheduleAt(testTime) {
            disposable.dispose()
        }
        return observer
    }
}
