import Foundation
import Bow
import BowOptics
import Interplate

public extension Collection {
    // cuts on left
    func cut<A, B>() -> [Pair<A?, [B]>] where Element == Either<A, B> {
        var cuts = [Pair<A?, [B]>]()
        var currentCut: Pair<A?, [B]>? = nil
        forEach { element in
            element.fold({ (a) -> Void in
                if let currentCut = currentCut {
                    cuts.append(currentCut)
                }
                currentCut = Pair(a, [])
            }) { (b) -> Void in
                if currentCut == nil { currentCut = Pair(nil, []) }
                currentCut?.b.append(b)
            }
        }
        if let currentCut = currentCut {
            cuts.append(currentCut)
        }
        return cuts
    }

    // cuts on left
    func cutMergingAdjacentLefts<A, B>() -> [Pair<[A], [B]>] where Element == Either<A, B> {
        var cuts = [Pair<[A], [B]>]()
        var currentCut: Pair<[A], [B]>? = nil
        var previousElementIsLeft = false
        forEach { element in
            element.fold({ (a) -> Void in
                if previousElementIsLeft {
                    if currentCut == nil { currentCut = Pair([], []) }
                    currentCut?.a.append(a)
                } else {
                    if let currentCut = currentCut {
                        cuts.append(currentCut)
                    }
                    currentCut = Pair([a], [])
                }
                previousElementIsLeft = true
            }) { (b) -> Void in
                if currentCut == nil { currentCut = Pair([], []) }
                currentCut?.b.append(b)
                previousElementIsLeft = false
            }
        }
        if let currentCut = currentCut {
            cuts.append(currentCut)
        }
        return cuts
    }

    // right is enclosed subsequences
    // abstract to "select stateful" or "classify stateful"?
    func enclosedSubSequences<A, B>() -> [Either<[B], [B]>]  where Element == Either<A, B> {
        var subSequences = [Either<[B], [B]>]()
        var isEnclosedSubsequence: Bool = false
        var currentSubSequence = [B]()
        forEach { element in
            element.fold({ (a) -> Void in
                if isEnclosedSubsequence {
                    if !currentSubSequence.isEmpty {
                        subSequences.append(.right(currentSubSequence))
                    }
                    isEnclosedSubsequence = false
                } else {
                    if !currentSubSequence.isEmpty {
                        subSequences.append(.left(currentSubSequence))
                    }
                    isEnclosedSubsequence = true
                }
                currentSubSequence = []
            }) { (b) -> Void in
                currentSubSequence.append(b)
            }
        }
        if !currentSubSequence.isEmpty {
            subSequences.append(.left(currentSubSequence))
            isEnclosedSubsequence = true
        }
        return subSequences
    }

    func mapMethod<T>(_ method: (Element) -> () -> T) -> [T] {
        let transforms: [() -> T] = map(method)
        return transforms.map { $0() }
    }
}

//extension Collection where Index: BinaryInteger {
//    public subscript(index: Index, default defaultValue: @autoclosure () -> Element) -> Element {
//        guard index >= 0, index < endIndex else {
//            return defaultValue()
//        }
//
//        return self[index]
//    }
//}

extension BidirectionalCollection where Element == Substring {
    func joined(separator: String = "") -> String {
        map(String.init).joined(separator: separator)
    }
}

public struct Pair<A, B>: AutoLens {
    public init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }

    public var a: A
    public var b: B

    public static func aPLens<U>() -> PLens<Self, Pair<U, B>, A, U> {
        PLens<Self, Pair<U, B>, A, U>(
            get: { $0.a },
            set: { whole, part in Pair<U, B>(part, whole.b)})
    }

    public static func bPLens<U>() -> PLens<Self, Pair<A, U>, B, U> {
        PLens<Self, Pair<A, U>, B, U>(
            get: { $0.b },
            set: { whole, part in Pair<A, U>(whole.a, part)})
    }
}

extension Pair: Equatable where A: Equatable, B: Equatable {}

extension PPrism {
    func or<C, D>(_ other: PPrism<S, T, C, D>) -> PPrism<S, T, Either<A, C>, Either<B, D>> {
        PPrism<S, T, Either<A, C>, Either<B, D>>(
            getOrModify: { s in
                self.getOrModify(s)
                    .mapLeft { _ in other.getOrModify(s) }
                    .swap()
                    .sequence()
                    .map { $0^ }^
            },
            reverseGet: { $0.fold(self.reverseGet, other.reverseGet) }
        )
    }
}

extension Prism where S == T, A == B {
    func filter(_ predicate: @escaping (A) -> Bool) -> Prism<S, A> {
        Prism<S, A>(
            getOrModify: { s in
                self.getOrModify(s).filterOrOther(predicate, { _ in s })
            },
            reverseGet: reverseGet
        )
    }
}

extension Comparable {
    func clamp(to lower: Self, _ upper: Self) -> Self {
        .max(
            .min(upper, self),
            self
        )
    }
}

protocol TemplateConvertible {
    var asTemplate: Template { get }
}

extension StringProtocol {
    var asTemplate: Template {
        "\(self)"
    }
}

extension String: TemplateConvertible {}
extension Substring: TemplateConvertible {}

extension Template: TemplateConvertible {
    var asTemplate: Template {
        self
    }
}

extension Template.StringInterpolation {
    func appendInterpolation(_ template: @autoclosure () -> TemplateConvertible) {
        appendLiteral(template().asTemplate.parts.joined())
    }
}
