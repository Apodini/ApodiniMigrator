import Foundation

enum MangledName: Equatable {
    case dictionary
    case repeated
    case optional
    case fluentPropertyType(FluentPropertyType)
    case other(String)

    init(_ mangledName: String) {
        switch mangledName {
        case "Optional": self = .optional
        case "Dictionary": self = .dictionary
        case "Array", "Set": self = .repeated
        case let other:
            if let fluentProperty = FluentPropertyType(rawValue: other.lowerFirst) {
                self = .fluentPropertyType(fluentProperty)
            } else {
                self = .other(other)
            }
        }
    }
}
