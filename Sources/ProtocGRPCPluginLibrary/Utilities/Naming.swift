//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

let swiftKeywordsUsedInDeclarations: Set<String> = [
    "associatedtype", "class", "deinit", "enum", "extension",
    "fileprivate", "func", "import", "init", "inout", "internal",
    "let", "open", "operator", "private", "protocol", "public",
    "static", "struct", "subscript", "typealias", "var"
]

let swiftKeywordsUsedInStatements: Set<String> = [
    "break", "case",
    "continue", "default", "defer", "do", "else", "fallthrough",
    "for", "guard", "if", "in", "repeat", "return", "switch", "where",
    "while"
]

let swiftKeywordsUsedInExpressionsAndTypes: Set<String> = [
    "as",
    "Any", "catch", "false", "is", "nil", "rethrows", "super", "self",
    "Self", "throw", "throws", "true", "try"
]

let quotableFieldNames: Set<String> = { () -> Set<String> in
    var names: Set<String> = []

    names = names.union(swiftKeywordsUsedInDeclarations)
    names = names.union(swiftKeywordsUsedInStatements)
    names = names.union(swiftKeywordsUsedInExpressionsAndTypes)
    return names
}()

let swiftCommonTypes: Set<String> = [
    "Bool", "Data", "Double", "Float", "Int",
    "Int32", "Int64", "String", "UInt", "UInt32", "UInt64"
]

let swiftSpecialVariables: Set<String> = [
    "__COLUMN__", "__FILE__", "__FUNCTION__", "__LINE__"
]

func sanitize(fieldName string: String) -> String {
    if quotableFieldNames.contains(string) {
        return "`\(string)`"
    }
    return string
}

private let reservedTypeNames: Set<String> = {
    () -> Set<String> in
    var names: Set<String> = []

    // Main SwiftProtobuf namespace
    // Shadowing this leads to Bad Things.
    names.insert("SwiftProtobuf")

    // Subtype of many messages, used to scope nested extensions
    names.insert("Extensions")

    // Subtypes are static references, so can conflict with static
    // class properties:
    names.insert("protoMessageName")

    // Methods on Message that we need to avoid shadowing.  Testing
    // shows we do not need to avoid `serializedData` or `isEqualTo`,
    // but it's not obvious to me what's different about them.  Maybe
    // because these two are generic?  Because they throw?
    names.insert("decodeMessage")
    names.insert("traverse")

    // Basic Message properties we don't want to shadow:
    names.insert("isInitialized")
    names.insert("unknownFields")

    // Standard Swift property names we don't want
    // to conflict with:
    names.insert("debugDescription")
    names.insert("description")
    names.insert("dynamicType")
    names.insert("hashValue")

    // We don't need to protect all of these keywords, just the ones
    // that interfere with type expressions:
    // names = names.union(swiftKeywordsReservedInParticularContexts)
    names.insert("Type")
    names.insert("Protocol")

    names = names.union(swiftKeywordsUsedInDeclarations)
    names = names.union(swiftKeywordsUsedInStatements)
    names = names.union(swiftKeywordsUsedInExpressionsAndTypes)
    names = names.union(swiftCommonTypes)
    names = names.union(swiftSpecialVariables)
    return names
}()

private func isAllUnderscore(_ string: String) -> Bool {
    if string.isEmpty {
        return false
    }
    for character in string.unicodeScalars where character != "_" {
        return false
    }
    return true
}

private func sanitizeTypeName(_ string: String, disambiguator: String, forbiddenTypeNames: Set<String>) -> String {
    // NOTE: This code relies on the protoc validation of _identifier_ is defined
    // (in Tokenizer::Next() as `[a-zA-Z_][a-zA-Z0-9_]*`, so this does not need
    // any complex validation or handing of characters outside those ranges. Since
    // those rules prevent a leading digit; nothing needs to be done, and any
    // explicitly use Message or Enum name will be valid. The one exception is
    // this code is also used for determining the OneOf enums, but that code is
    // responsible for dealing with the issues in the transforms it makes.
    if reservedTypeNames.contains(string) {
        return string + disambiguator
    } else if isAllUnderscore(string) {
        return string + disambiguator
    } else if string.hasSuffix(disambiguator) {
        // If `foo` and `fooMessage` both exist, and `foo` gets
        // expanded to `fooMessage`, then we also should expand
        // `fooMessage` to `fooMessageMessage` to avoid creating a new
        // conflict.  This can be resolved recursively by stripping
        // the disambiguator, sanitizing the root, then re-adding the
        // disambiguator:
        let e = string.index(string.endIndex, offsetBy: -disambiguator.count) // swiftlint:disable:this identifier_name
        let truncated = String(string[..<e])
        return sanitizeTypeName(truncated, disambiguator: disambiguator, forbiddenTypeNames: forbiddenTypeNames) + disambiguator
    } else if forbiddenTypeNames.contains(string) {
        // NOTE: It is important that this case runs after the hasSuffix case.
        // This set of forbidden type names is not fixed, and may contain something
        // like "FooMessage". If it does, and if s is "FooMessage with a
        // disambiguator of "Message", then we want to sanitize on the basis of
        // the suffix rather simply appending the disambiguator.
        // We use this for module imports that are configurable (like SwiftProtobuf
        // renaming).
        return string + disambiguator
    } else {
        return string
    }
}

enum GRPCNamingUtils {
    // Returns the type prefix to use for a given
    static func typePrefix(protoPackage: String) -> String {
        if protoPackage.isEmpty {
            return String()
        }

        // NOTE: This code relies on the protoc validation of proto packages. Look
        // at Parser::ParsePackage() to see the logic, it comes down to reading
        // _identifiers_ joined by '.'.  And _identifier_ is defined (in
        // Tokenizer::Next() as `[a-zA-Z_][a-zA-Z0-9_]*`, so this does not need
        // any complex validation or handing of characters outside those ranges.
        // It just has to deal with ended up with a leading digit after the pruning
        // of '_'s.

        // Transforms:
        //  "package.name" -> "Package_Name"
        //  "package_name" -> "PackageName"
        //  "package.some_name" -> "Package_SomeName"
        var prefix = String.UnicodeScalarView()
        var makeUpper = true
        for character in protoPackage.unicodeScalars {
            if character == "_" {
                makeUpper = true
            } else if character == "." {
                makeUpper = true
                prefix.append("_")
            } else {
                if prefix.isEmpty && character.isASCDigit {
                    // If the first character is going to be a digit, add an underscore
                    // to ensure it is a valid Swift identifier.
                    prefix.append("_")
                }
                if makeUpper {
                    prefix.append(character.ascUppercased())
                    makeUpper = false
                } else {
                    prefix.append(character)
                }
            }
        }
        // End in an underscore to split off anything that gets added to it.
        return String(prefix) + "_"
    }

    static func sanitize(messageName name: String, forbiddenTypeNames: Set<String>) -> String {
        sanitizeTypeName(name, disambiguator: "Message", forbiddenTypeNames: forbiddenTypeNames)
    }

    static func sanitize(enumName name: String, forbiddenTypeNames: Set<String>) -> String {
        sanitizeTypeName(name, disambiguator: "Enum", forbiddenTypeNames: forbiddenTypeNames)
    }

    static func sanitize(oneofName name: String, forbiddenTypeNames: Set<String>) -> String {
        sanitizeTypeName(name, disambiguator: "Oneof", forbiddenTypeNames: forbiddenTypeNames)
    }
}

extension UnicodeScalar {
    /// True if the receiver is a numeric digit.
    var isASCDigit: Bool {
        if case "0"..."9" = self {
            return true
        }
        return false
    }

    /// True if the receiver is a lowercase character.
    var isASCLowercase: Bool {
        if case "a"..."z" = self {
            return true
        }
        return false
    }

    /// Returns the uppercased version of the receiver, or the receiver itself if
    /// it is not a cased character.
    ///
    /// - Precondition: The receiver is 7-bit ASCII.
    /// - Returns: The uppercased version of the receiver, or `self`.
    func ascUppercased() -> UnicodeScalar {
        if isASCLowercase {
            return UnicodeScalar(value - 0x20)! // swiftlint:disable:this force_unwrapping
        }
        return self
    }
}
