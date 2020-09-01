import XCTest
import GenerateDocsComponentLib
import Bow
import BowOptics

final class CollectionCutMergingAdjacentTests: XCTestCase {
    func testEmptyArray() throws {
        let result = "".testCut()
        XCTAssertEqual(result, [])
    }

    func test1() {
        let result = "ooxooxxoo".testCut()
        XCTAssertEqual(result, [Pair("", "oo"), Pair("x", "oo"), Pair("xx", "oo")])
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
        XCTAssertEqual(result, [Pair("", "o"), Pair("x", "")])
    }

    func test5() {
        let result = "xoox".testCut()
        XCTAssertEqual(result, [Pair("x", "oo"), Pair("x", "")])
    }
}

fileprivate extension String {
    func testCut() -> [Pair<String, String>] {
        map { $0 == "x" ? Either.left($0) : Either.right($0) }
            .cutMergingAdjacentLefts()
            .joinCharacters()
    }
}

fileprivate extension Array where Element == Pair<[String.Element], [String.Element]> {
    func joinCharacters() -> Array<Pair<String, String>> {
        map { Pair<[Character], [Character]>.aPLens().modify($0, { c in String(c) }) }
        .map { Pair<String, [Character]>.bPLens().modify($0, { c in String(c) }) }
    }
}
