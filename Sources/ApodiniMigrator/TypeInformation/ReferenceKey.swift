import Foundation

/// A `ReferenceKey` uniquely identifies a `typeInformation` stored in `TypesStore`
public struct ReferenceKey: Value, RawRepresentable {
    /// Raw value
    public let rawValue: String

    /// Initializes self from a rawValue
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Initializes self from a rawValue
    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
    
    /// Initializes self from a RawRepresentable instance with string raw value
    public init<R: RawRepresentable>(_ rawRepresentable: R) where R.RawValue == String {
        self.rawValue = rawRepresentable.rawValue
    }

    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    /// Encodes self into the given encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: - CustomStringConvertible + CustomDebugStringConvertible
extension ReferenceKey: CustomStringConvertible, CustomDebugStringConvertible {
    /// String description of self
    public var description: String { rawValue }
    /// String description of self
    public var debugDescription: String { rawValue }
}

// MARK: - Hashable
public extension ReferenceKey {
    /// :nodoc:
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

// MARK: - Equatable
public extension ReferenceKey {
    /// :nodoc:
    static func == (lhs: ReferenceKey, rhs: ReferenceKey) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
