import Foundation

/// A similar to `NSNull` type that encodes `nil`
public struct Null: Value {
    /// Initializer for `self`
    public init() {}
    
    // MARK: - Decodable
    public init(from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        guard singleValueContainer.decodeNil() else {
            throw DecodingError.dataCorruptedError(in: singleValueContainer, debugDescription: "Expected to decode `null`")
        }
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
