//
//  ApodiniMigratorCodable.swift
//  ApodiniMigratorClientSupport
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// `Encodable` protocol with additional type constraint to introduce a `JSONEncoder`
public protocol ApodiniMigratorEncodable: Encodable {
    static var encoder: JSONEncoder { get }
}

/// `Decodable` protocol with additional type constraint to introduce a `JSONDecoder`
public protocol ApodiniMigratorDecodable: Decodable {
    static var decoder: JSONDecoder { get }
}

/// A protocol similar to `Codable` typealias, but with the additional constraint that conforming types
/// should introduce a `JSONEncoder` and `JSONDecoder`. Supported primitive types by `ApodiniMigrator`
/// conform to `ApodiniMigratorCodable` by default.
/// - Note: Arrays conform by default to `ApodiniMigratorCodable` if `Element: ApodiniMigratorCodable`.
/// Optional conforms by default to `ApodiniMigratorCodable` if `Wrapped: ApodiniMigratorCodable`.
/// Dictionary conforms by default to `ApodiniMigratorCodable` if `Element: ApodiniMigratorCodable` and `Key: Codable`
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

// MARK: - Array + ApodiniMigratorCodable
extension Array: ApodiniMigratorDecodable where Element: ApodiniMigratorDecodable {
    public static var decoder: JSONDecoder {
        Element.decoder
    }
}

extension Array: ApodiniMigratorEncodable where Element: ApodiniMigratorEncodable {
    public static var encoder: JSONEncoder {
        Element.encoder
    }
}

extension Array: ApodiniMigratorCodable where Element: ApodiniMigratorCodable {}

// MARK: - Dictionary + ApodiniMigratorCodable
extension Dictionary: ApodiniMigratorEncodable where Key: Encodable, Value: ApodiniMigratorEncodable {
    public static var encoder: JSONEncoder {
        Value.encoder
    }
}

extension Dictionary: ApodiniMigratorDecodable where Key: Decodable, Value: ApodiniMigratorDecodable {
    public static var decoder: JSONDecoder {
        Value.decoder
    }
}

extension Dictionary: ApodiniMigratorCodable where Key: Codable, Value: ApodiniMigratorCodable {}

// MARK: - Optional + ApodiniMigratorCodable
extension Optional: ApodiniMigratorEncodable where Wrapped: ApodiniMigratorEncodable {
    public static var encoder: JSONEncoder {
        Wrapped.encoder
    }
}

extension Optional: ApodiniMigratorDecodable where Wrapped: ApodiniMigratorDecodable {
    public static var decoder: JSONDecoder {
        Wrapped.decoder
    }
}

extension Optional: ApodiniMigratorCodable where Wrapped: ApodiniMigratorCodable {}
