//
// Created by Andreas Bauer on 22.12.21.
//

import Foundation

extension TypeInformation {
    /// TODO explain why this isn't ideal, but isn't any worse than existing stuff!
    var unsafeFileNaming: String {
        switch self {
        case let .reference(key):
            return TypeName(rawValue: key.rawValue).mangledName
        default:
            // TODO file name uniqueness
            return typeName.mangledName
        }
    }

    var unsafeTypeString: String {
        switch self {
        case let .repeated(element):
            return "[\(element.unsafeTypeString)]"
        case let .dictionary(key, value):
            return "[\(key.description): \(value.unsafeTypeString)]"
        case let .optional(wrappedValue):
            return wrappedValue.unsafeTypeString + "?"
        case .enum, .object, .scalar:
            return typeString
        case let .reference(key):
             return TypeName(rawValue: key.rawValue).buildName()
        }
    }
}
