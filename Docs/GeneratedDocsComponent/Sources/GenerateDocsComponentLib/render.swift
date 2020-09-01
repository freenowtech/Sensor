import Foundation
import Interplate
import Ink

public func render(_ pages: [Page]) -> [(fileName: String, content: String)] {
    let sidebar = sidebarTemplate(for: pages)
    return pages.map { page in
        (
            fileName: page.filename,
            content: template(for: page, withSidebar: sidebar).render()
        )
    }
}

public struct Page {
    public init(title: String, sections: [Section]) {
        self.title = title
        self.sections = sections
    }

    public let title: String
    public let sections: [Section]

    public var filename: String {
        title.replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: ".", with: "_")
            + ".html"
    }
}

fileprivate func sidebarTemplate(for pages: [Page]) -> Template {
    """
    <div class="sidebar">
    \(for: pages, do: { page, i in
        """
        <div class="sidebarElement">\(link: page.title, href: page.filename, inverted: true)</div>\n
        """
    })
    </div>
    """
}

fileprivate func template(for page: Page, withSidebar sidebar: Template) -> Template {
    """
    <html>
    <head>
        <link rel="stylesheet" type="text/css" href="../main.css">
        <link rel="stylesheet"
            href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.0.0/styles/xcode.min.css">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.0.0/highlight.min.js"></script>
        <script charset="UTF-8"
            src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.0.0/languages/swift.min.js"></script>
        <script>hljs.initHighlightingOnLoad();</script>
    </head>
    <body>
        <div class="main">
            \(sidebar)
            <div class="content">
                \(for: page.sections, do: { section, _ in "\(template(for: section))\n" })
            </div>
        </div>
    </body>
    </html>
    """
}

fileprivate func template(for section: Section) -> Template {
    let header = section.header.map { header in "\(headline: header.wrapped, level: header.level)" as Template } ?? ""

    return """
    <div>
    \(header)
    \(for: section.chunks, do: { chunk, _ in "\(template(for: chunk))\n" })
    </div>
    """
}

fileprivate func template(for chunk: Chunk) -> Template {
    switch chunk.code.isEmpty {
    case true:
        return template(forCommentOnlyChunk: chunk)
    case false:
        return template(forChunkWithCode: chunk)
    }
}

fileprivate func template(forCommentOnlyChunk chunk: Chunk) -> Template {
    let comments = parseMarkdown(
        chunk.comment
            .map(\.trimmed)
            .joined(separator: "\n")
    )
    return """
    <div class="row">
        <div class="comments text">
            \(comments)
        </div>
    </div>
    """
}

fileprivate func template(forChunkWithCode chunk: Chunk) -> Template {
    let comments = parseMarkdown(
        chunk.comment
            .map(\.trimmed)
            .joined(separator: "\n")
    )
    let code = chunk.code.joined(separator: "\n")
    return """
    <div class="row">
        <div class="comments column">
            \(text: comments)
        </div>
        <div class="code column">
            \(text: """
                <pre><code class="swift">
            \(code)
                </pre></code>
            """)
        </div>
    </div>
    """
}

fileprivate func parseMarkdown(_ text: String) -> String {
    var parser = MarkdownParser()
    parser.addModifier(Modifier(target: .inlineCode) { html, markdown in
        // Drop <code> tags
        let code = html.dropFirst(6).dropLast(7)
        return """
        <code class="inlineCode">\(code)</code>
        """
    })
    parser.addModifier(Modifier(target: .links) { html, markdown in
        guard let closingBracketIndex = markdown.firstIndex(of: "]") else { return html }
        let firstUrlCharacterIndex = markdown.index(closingBracketIndex, offsetBy: 2)
        let text = markdown.dropFirst().prefix(upTo: closingBracketIndex)
        let url = markdown.suffix(from: firstUrlCharacterIndex).dropLast()
        return ("""
        \(link: text, href: url)
        """ as Template).render()
    })
    return parser.html(from: String(text))
}

// MARK: - Components

extension Template.StringInterpolation {
    func appendInterpolation<S: TemplateConvertible>(headline: S, level: UInt, inverted: Bool = false) {
        appendInterpolation("""
            <h\(level) class="headline\(invertedClass(inverted))">\(headline)</h\(level)>
            """
        as Template)
    }

    func appendInterpolation<S: TemplateConvertible>(text: S, weak: Bool = false, inverted: Bool = false) {
        appendInterpolation("""
            <span class="text\(invertedClass(inverted))\(weakClass(weak))">\(text.asTemplate)</span>
            """
        as Template)
    }

    func appendInterpolation<S1: TemplateConvertible, S2: TemplateConvertible>(link: S1, href: S2, inverted: Bool = false) {
        appendInterpolation("""
            <a href="\(href.asTemplate)" class="link\(invertedClass(inverted))">\(link.asTemplate)</a>
            """
        as Template)
    }
}

fileprivate func invertedClass(_ inverted: Bool) -> String {
    inverted ? " inverted" : ""
}

fileprivate func weakClass(_ weak: Bool) -> String {
    weak ? " weak" : ""
}
