import Foundation

enum MangledName: Equatable {
    case dictionary
    case repeated
    case optional
    case fluentPropertyType(FluentPropertyType)
    case other(String)
    
    var isFluentPropertyType: Bool {
        if case .fluentPropertyType = self {
            return true
        }
        return false
    }
    
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
