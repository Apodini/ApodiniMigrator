import Foundation
@_implementationOnly import Runtime

enum MangledName: Equatable {
    case dictionary
    case array
    case optional
    case other(String)
    
    init(_ mangledName: String) {
        switch mangledName {
        case "Optional": self = .optional
        case "Dictionary": self = .dictionary
        case "Array": self = .array
        case let other: self = .other(other)
        }
    }
}

extension TypeInfo {
    // swiftlint:disable:next identifier_name
    var _mangledName: MangledName {
        .init(mangledName)
    }
}
