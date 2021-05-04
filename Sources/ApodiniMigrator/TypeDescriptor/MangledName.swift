

import Foundation

enum MangledName: Equatable {
    case dictionary
    case repeated
    case optional
    case other(String)
    
    init(_ mangledName: String) {
        switch mangledName {
        case "Optional": self = .optional
        case "Dictionary": self = .dictionary
        case "Array", "Set": self = .repeated
        case let other: self = .other(other)
        }
    }
}
