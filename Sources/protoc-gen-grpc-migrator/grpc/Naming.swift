//
// Created by Andreas Bauer on 06.12.21.
//

import Foundation

// TODO placement!
let swiftKeywordsUsedInDeclarations: Set<String> = [
    "associatedtype", "class", "deinit", "enum", "extension",
    "fileprivate", "func", "import", "init", "inout", "internal",
    "let", "open", "operator", "private", "protocol", "public",
    "static", "struct", "subscript", "typealias", "var",
]

let swiftKeywordsUsedInStatements: Set<String> = [
    "break", "case",
    "continue", "default", "defer", "do", "else", "fallthrough",
    "for", "guard", "if", "in", "repeat", "return", "switch", "where",
    "while",
]

let swiftKeywordsUsedInExpressionsAndTypes: Set<String> = [
    "as",
    "Any", "catch", "false", "is", "nil", "rethrows", "super", "self",
    "Self", "throw", "throws", "true", "try",
]

let quotableFieldNames: Set<String> = { () -> Set<String> in
    var names: Set<String> = []

    names = names.union(swiftKeywordsUsedInDeclarations)
    names = names.union(swiftKeywordsUsedInStatements)
    names = names.union(swiftKeywordsUsedInExpressionsAndTypes)
    return names
}()
