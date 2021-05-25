//
//  Utils.swift
//
//  Created by ApodiniMigrator on 25.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
@_exported import ApodiniMigratorClientSupport

/// A typealias of `ApodiniMigratorDecodable`, a `Decodable` protocol
/// with additional type constraint to introduce a `JSONDecoder`
public typealias Decodable = ApodiniMigratorDecodable

/// A typealias of `ApodiniMigratorEncodable`, an `Encodable` protocol
/// with additional type constraint to introduce a `JSONEncoder`
public typealias Encodable = ApodiniMigratorEncodable

/// An override typealias of `Foundation.Codable` for `ApodiniMigratorCodable`
public typealias Codable = ApodiniMigratorCodable

/// `ApodiniMigratorCodable` default implementation
public extension ApodiniMigratorCodable {
    /// `JSONEncoder` used to encode `self`
    static var encoder: JSONEncoder {
        NetworkingService.encoder
    }
    
    /// `JSONDecoder` used to decode `Self.self`
    static var decoder: JSONDecoder {
        NetworkingService.decoder
    }
}

/// Date conformance to `ApodiniMigratorCodable`
extension Date: Codable {}
/// Data conformance to `ApodiniMigratorCodable`
extension Data: Codable {}
