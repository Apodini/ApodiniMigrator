import Foundation

/// A `ReferenceKey` uniquely identifies a `typeInformation` stored in `TypesStore`
public struct ReferenceKey: Value, RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
    
    public init<R: RawRepresentable>(_ rawRepresentable: R) where R.RawValue == String {
        self.rawValue = rawRepresentable.rawValue
    }

    public init(from decoder: Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension ReferenceKey: CustomStringConvertible {
    public var description: String { rawValue }
}

public extension ReferenceKey {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

public extension ReferenceKey {
    static func == (lhs: ReferenceKey, rhs: ReferenceKey) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
