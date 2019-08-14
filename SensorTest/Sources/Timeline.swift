//
//  Timeline.swift
//  SensorTest
//
//  Created by Ferran Pujol Camins on 30/05/2019.
//

import Foundation
import RxSwift
import RxTest

func timeline<Element>(for recordedEvents: [TestTime : [Recorded<Event<Element>>]], withValues valuesDict: [String: Element], andErrors errorsDict: [String: Error]) -> String where Element: Equatable {
    func symbolFor(_ element: Element) -> String? {
        return valuesDict.first(where: {
            return element == $0.value
        })?.key
    }

    func symbolFor(error: Error) -> String? {
        return errorsDict.first(where: {
            // Hack so we can use the event error equality defined in RxTest
            return Event<Bool>.error(error) == Event<Bool>.error($0.value)
        })?.key
    }

    let symbolsAtTime: [TestTime: [String]] = recordedEvents.mapValues { $0.map { event in
        switch event.value {
        case .next(let element):
            return symbolFor(element) ?? "¿"
        case .error(let error):
            return symbolFor(error: error) ?? "#"
        case .completed:
            return "|"
        }
    }}

    let symbolsTimelineDict: [TestTime: String] = symbolsAtTime.mapValues { symbols -> String in
        if symbols.count > 1 {
            return "(\(symbols.joined()))"
        } else {
            return symbols.joined()
        }
    }

    let maxTime = symbolsTimelineDict.keys.max() ?? 0
    let timeline = (0...maxTime).map { t in
        return symbolsTimelineDict[t] ?? "-"
    }

    return timeline.joined()
}
