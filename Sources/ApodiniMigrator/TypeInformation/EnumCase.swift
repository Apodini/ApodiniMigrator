import Foundation


public enum RawValueType: String, Value {
    case int
    case string
    
    init<R: RawRepresentable>(_ rawRepresentable: R.Type) {
        let rawValueTypeString = String(describing: R.RawValue.self)
        if let rawValueType = Self(rawValue: rawValueTypeString.lowerFirst) {
            self = rawValueType
        } else {
            fatalError("\(R.RawValue.self) is currently not supported")
        }
    }
}

public struct EnumCase: Value {
    public let name: String
    public let rawValue: String
    
    public init(_ name: String) {
        self.name = name
        self.rawValue = name
    }
    
    public init(_ name: String, rawValue: String) {
        self.name = name
        self.rawValue = rawValue
    }
}

extension EnumCase: DeltaIdentifiable {
    public var deltaIdentifier: DeltaIdentifier { .init(name) }
}

public extension EnumCase {
    static func `case`(_ name: String) -> EnumCase {
        .init(name)
    }
}
