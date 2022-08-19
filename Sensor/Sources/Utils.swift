//
//  Utils.swift
//  Sensor
//
//  Created by Ferran Pujol Camins on 08/10/2019.
//

import Foundation
import RxSwift
import RxCocoa

extension Signal {
    func pairwise() -> Signal<(Element, Element)> {
        return asObservable().pairwise().asSignal(onErrorSignalWith: .empty())
    }
}

extension Array where Element: Hashable {
    // Precondition: Arrays don't have repeated elements
    func removingElements(from otherArray: [Element]) -> [Element] {
        // We iterate over otherArray, the list with the elements we want to remove from self.
        // We "accumulate" over self, and we operate on every element of otherArray by removing it
        // from self.
        return otherArray.reduce(self) { (reducedSelf, elementToRemove) -> [Element] in
            reducedSelf.removingFirstOccurrence(of: elementToRemove)
        }
    }
}

extension Array where Element: Equatable{
    func removingFirstOccurrence(of e: Element) -> Array {
        guard let index = firstIndex(of: e) else { return self }
        var copy = self
        copy.remove(at: index)
        return copy
    }
}
