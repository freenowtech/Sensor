import XCTest
import GenerateDocsComponentLib
import Bow
import BowOptics

final class CollectionCutTests: XCTestCase {
    func testEmptyArray() throws {
        let result = "".testCut()
        XCTAssertEqual(result, [])
    }

    func test1() {
        let result = "ooxooxxoo".testCut()
        XCTAssertEqual(result, [Pair(nil, "oo"), Pair("x", "oo"), Pair("x", ""), Pair("x", "oo")])
    }

    func test2() {
        let result = "xo".testCut()
        XCTAssertEqual(result, [Pair("x", "o")])
    }

    func test3() {
        let result = "x".testCut()
        XCTAssertEqual(result, [Pair("x", "")])
    }

    func test4() {
        let result = "ox".testCut()
        XCTAssertEqual(result, [Pair(nil, "o"), Pair("x", "")])
    }

    func test5() {
        let result = "xoox".testCut()
        XCTAssertEqual(result, [Pair("x", "oo"), Pair("x", "")])
    }
}

fileprivate extension String {
    func testCut() -> [Pair<Character?, String>] {
        map { $0 == "x" ? Either.left($0) : Either.right($0) }
            .cut()
            .joinCharacters()
    }
}

fileprivate extension Array where Element == Pair<String.Element?, [String.Element]> {
    func joinCharacters() -> Array<Pair<Character?, String>> {
        map { Pair<Character?, [Character]>.bPLens().modify($0, { c in String(c) }) }
    }
}
