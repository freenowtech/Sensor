import XCTest
import GenerateDocsComponentLib
import Bow
import BowOptics

final class EnclosedSubSequencesTests: XCTestCase {
    func testEmptyArray() throws {
        let result = "".testEnclosedSubSequences()
        XCTAssertEqual(result, [])
    }

    func test1() {
        let result = "_".testEnclosedSubSequences()
        XCTAssertEqual(result, [])
    }

    func test2() {
        let result = "_a_o_fe".testEnclosedSubSequences()
        XCTAssertEqual(result, [.right("a"), .left("o"), .left("fe")])
    }

    func test3() {
        let result = "oo_oo__oo".testEnclosedSubSequences()
        XCTAssertEqual(result, [.left("oo"), .right("oo"), .left("oo")])
    }

    func test4() {
        let result = "oo_ab_o_c_oo".testEnclosedSubSequences()
        XCTAssertEqual(result, [.left("oo"), .right("ab"), .left("o"), .right("c"), .left("oo")])
    }

    func test5() {
        let result = "_ab_o_c_".testEnclosedSubSequences()
        XCTAssertEqual(result, [.right("ab"), .left("o"), .right("c")])
    }

    func test6() {
        let result = "_ab__c_".testEnclosedSubSequences()
        XCTAssertEqual(result, [.right("ab"), .right("c")])
    }
}

fileprivate extension String {
    func testEnclosedSubSequences() -> [Either<String, String>] {
        map { $0 == "_" ? Either.left($0) : Either.right($0) }
            .enclosedSubSequences()
            .map { e in e.bimap({ String($0) }, { String($0) }) }
    }
}

fileprivate extension Array where Element == Pair<String.Element?, [String.Element]> {
    func joinCharacters() -> Array<Pair<Character?, String>> {
        map { Pair<Character?, [Character]>.bPLens().modify($0, { c in String(c) }) }
    }
}
