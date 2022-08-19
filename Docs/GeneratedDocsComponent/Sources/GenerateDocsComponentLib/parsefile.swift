import Foundation
import Path
import Bow
import BowOptics
import Ink

// Lines starting with this string will be considered comments,
// all other lines will be considered code.
let commentString = "//"

let codeBlockString = "```"

fileprivate let headerCharacter = Character("#")

// MARK: - Data structures

typealias Code = Substring

enum Line: AutoPrism {
    case header(Header)
    case comment(Comment)
    case code(Code)

    func extractHeader() -> Either<Header, CommentOrCodeLine> {
        switch self {
        case .header(let header):
            return .left(header)
        case .comment(let comment):
            return .right(.left(comment))
        case .code(let code):
            return .right(.right(code))
        }
    }

    var commentOrCode: Prism<Line, Either<Comment, Code>> {
        Line.prism(for: Line.comment).or(Line.prism(for: Line.code))
    }
}

typealias CommentOrCodeLine = Either<Comment, Code>

struct Comment {
    let trimmed: Substring
    let untrimmed: Substring

    init?<S: StringProtocol>(_ wrapped: S) {
        let trimmed = wrapped.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix(commentString) else { return nil }

        self.untrimmed = trimmed
            .dropFirst(commentString.count)
        self.trimmed = untrimmed
            .drop(while: \.isWhitespace)
    }
}

struct Header {
    let wrapped: String
    let level: UInt

    init?(_ comment: Comment) {
        var parsedLevel: UInt?
        var parser = MarkdownParser()
        parser.addModifier(Modifier(target: .headings) { html, markdown in
            parsedLevel = UInt(String(html.dropFirst(2).prefix(1)))
            let headline = markdown
                .trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: "#"))
                .trimmingCharacters(in: .whitespaces)
            return headline
        })
        self.wrapped = parser.html(from: String(comment.trimmed))
        guard let level = parsedLevel else { return nil }
        self.level = level
    }
}

struct Chunk {
    let comment: [Comment]
    let code: [Substring]

    init(_ pair: Pair<[Comment], [Substring]>) {
        comment = pair.a
        code = pair.b
            .filter { !$0.allSatisfy(\.isWhitespace) }
    }
}

enum ChunkOrHeader {
    case chunk(Chunk)
    case header(Header)
}

struct UnparsedSection: AutoLens {
    var header: Header?
    var commentOrCode: [CommentOrCodeLine]

    init(_ pair: Pair<Header?, [CommentOrCodeLine]>) {
        header = pair.a
        commentOrCode = pair.b
    }
}

public struct Section {
    let header: Header?
    let chunks: [Chunk]
}

// MARK: - Parsing

public func parseFile(_ path: Path) -> Page {
    let fileContents = try! String(contentsOf: path)
    let lines = linesOf(fileContents)
    let sections = parseLines(lines)
    let title = sections
        .first
        .flatMap(\.header?.wrapped)
    return Page(
        title: title ?? "Untitled",
        sections: sections
    )
}

fileprivate func linesOf(_ fileContents: String) -> [Line] {
    let rawLines = fileContents.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
    return rawLines.map(lexLine)
}

fileprivate func lexLine(_ rawLine: Substring) -> Line {
    if let comment = Comment(rawLine) {
        if let header = Header(comment) {
            return .header(header)
        }
        return .comment(comment)
    }
    return .code(rawLine)
}

fileprivate func parseLines(_ lines: [Line]) -> [Section] {
    let unparsedSections = lines.mapMethod(Line.extractHeader).cut()
        .map(UnparsedSection.init)

    let commentOrCodeLinesTraversal = [UnparsedSection].traversal + UnparsedSection.lens(for: \.commentOrCode)

    let unparsedSectionsWithParsedCodeBlocks = commentOrCodeLinesTraversal.modify(unparsedSections, parseMarkdownCodeBlocks)

    return unparsedSectionsWithParsedCodeBlocks.map { unparsedSection in
        let chunks = chunksFor(unparsedSection.commentOrCode)
        return Section(header: unparsedSection.header, chunks: chunks)
    }
}

fileprivate func parseMarkdownCodeBlocks(_ lines: [CommentOrCodeLine]) -> [CommentOrCodeLine] {
    let codeBlockDelimitersPrism = CommentOrCodeLine.leftPrism.filter(\.trimmed.isCodeBlockDelimiter)

    return lines.map(codeBlockDelimitersPrism.getOrModify)
        .mapMethod(Either.swap)
        .enclosedSubSequences()
        .flatMap(convertMarkdownCodeBlocksToRegularCode)
}

fileprivate func convertMarkdownCodeBlocksToRegularCode(_ e: Either<[Either<Comment, Code>], [Either<Comment, Code>]>) -> [Either<Comment, Code>] {
    e.map { (commentOrCodeLines: [Either<Comment, Code>]) in
        commentOrCodeLines.map { (commentOrCode: Either<Comment, Code>) -> Either<Comment, Code> in
            commentOrCode
                .swap()
                .flatMap { (comment) -> Either<Code, Comment> in
                    .left(comment.untrimmed)
                }^
            .swap()
        }
    }^
    .fold(id, id)
}

fileprivate func chunksFor(_ commentOrCodeLines: [CommentOrCodeLine]) -> [Chunk] {
    return commentOrCodeLines.cutMergingAdjacentLefts()
        .map(Chunk.init)
}

extension StringProtocol {
    var isCodeBlockDelimiter: Bool {
        starts(with: codeBlockString)
    }
}
