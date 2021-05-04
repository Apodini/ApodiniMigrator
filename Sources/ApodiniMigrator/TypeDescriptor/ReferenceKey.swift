import Foundation

/// A `ReferenceKey` uniquely identifies an object in stored in TypesStore
struct ReferenceKey: Value, RawRepresentable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
    
    init<R: RawRepresentable>(_ rawRepresentable: R) where R.RawValue == String {
        self.rawValue = rawRepresentable.rawValue
    }

    init(from decoder: Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension ReferenceKey: CustomStringConvertible {
    public var description: String { rawValue }
}

extension ReferenceKey {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension ReferenceKey {
    static func == (lhs: ReferenceKey, rhs: ReferenceKey) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
