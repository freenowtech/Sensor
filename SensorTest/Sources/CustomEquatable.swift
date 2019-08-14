//
//  CustomEquatable.swift
//  SensorTest
//
//  Created by Ferran Pujol Camins on 01/06/2019.
//

import Foundation
import RxSwift
import RxTest

struct CustomEquatable<E>: Equatable {
    let value: E
    let equals: (E) -> Bool

    static func == (lhs: CustomEquatable<E>, rhs: CustomEquatable<E>) -> Bool {
        return lhs.equals(rhs.value)
    }
}

struct AnyError: Error {
    var localizedDescription: String {
        return "Any Error"
    }
}

extension Event where Element: Equatable {
    func asCustomEquatable() -> CustomEquatable<Event<Element>> {
        return CustomEquatable(value: self, equals: { (event: Event) -> Bool in
            switch (self, event) {
            case (.error(let error), .error) where error is AnyError:
                return true
            case (.error, .error(let error)) where error is AnyError:
                return true
            default:
                // fall back to equality defined in RxTest
                return self == event
            }
        })
    }
}
