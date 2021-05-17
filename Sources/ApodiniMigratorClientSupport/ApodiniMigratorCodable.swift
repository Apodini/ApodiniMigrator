import Foundation

/// `Encodable` protocol with additional constraint to introduce a `JSONEncoder`
public protocol ApodiniMigratorEncodable: Encodable {
    static var encoder: JSONEncoder { get }
}

/// `Decodable` protocol with additional constraint to introduce a `JSONDecoder`
public protocol ApodiniMigratorDecodable: Decodable {
    static var decoder: JSONDecoder { get }
}

/// A protocol similar to `Codable` typealias, but with the additional constraint that conforming types
/// should introduce an `JSONEncoder` and `JSONDecoder`. Supported primitive types by `ApodiniMigrator`
/// conform to `ApodiniMigratorCodable` by default
public protocol ApodiniMigratorCodable: ApodiniMigratorEncodable, ApodiniMigratorDecodable {}

// MARK: - ApodiniMigratorCodable conformance
extension Int: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension Int8: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension Int16: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension Int32: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension Int64: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension UInt: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension UInt8: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension UInt16: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension UInt32: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension UInt64: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension Bool: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension Double: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension Float: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension String: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension URL: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}

extension UUID: ApodiniMigratorCodable {
    public static let encoder = JSONEncoder()
    public static let decoder = JSONDecoder()
}
