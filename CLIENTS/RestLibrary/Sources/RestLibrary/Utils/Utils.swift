//
//  Created by ApodiniMigrator on 06.12.21
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import ApodiniMigratorClientSupport

/// A typealias of `ApodiniMigratorDecodable`, a `Decodable` protocol
/// with additional type constraint to introduce a `JSONDecoder`
public typealias Decodable = ApodiniMigratorDecodable

/// A typealias of `ApodiniMigratorEncodable`, an `Encodable` protocol
/// with additional type constraint to introduce a `JSONEncoder`
public typealias Encodable = ApodiniMigratorEncodable

/// An override typealias of `Foundation.Codable` for `ApodiniMigratorCodable`
public typealias Codable = ApodiniMigratorCodable

/// `ApodiniMigratorEncodable` default implementation
public extension Encodable {
    /// `JSONEncoder` used to encode `self`
    static var encoder: JSONEncoder {
        NetworkingService.encoder
    }
}

/// `ApodiniMigratorDecodable` default implementation
public extension Decodable {
    /// `JSONDecoder` used to decode `Self.self`
    static var decoder: JSONDecoder {
        NetworkingService.decoder
    }
}

/// Date conformance to `ApodiniMigratorCodable`
extension Date: Codable {}
/// Data conformance to `ApodiniMigratorCodable`
extension Data: Codable {}

/// JSScript conformance to `ApodiniMigratorCodable`
extension JSScript: Codable {}
/// JSONValue conformance to `ApodiniMigratorCodable`
extension JSONValue: Codable {}

/// Holds distincts resource cases with the name of the resource as raw value
private enum Resource: String {
    /// Javascript convert methods
    case jsScripts = "js-convert-scripts"
    /// JSON values
    case jsonValues = "json-values"
}

/// Bundle extension for resource handling
fileprivate extension Bundle {
    /// Returns the typed instance at `resource`
    func resource<D: Decodable>(_ resource: Resource) -> D {
        guard
            let path = path(forResource: resource.rawValue, ofType: "json"),
            let instance = try? D.decode(from: path.asPath) else {
            fatalError("Resource \(resource.rawValue) is malformed")
        }
        return instance
    }
}

/// A caseless enum that initializes and holds js convert functions and json values
/// Is used in `ExpressibleByIntegerLiteral` initializers of `JSScript` and `JSONValue`
private enum Resources {
    /// Module bundle
    private static var bundle = Bundle.module
    
    /// Dictionary of js scripts with keys as id
    private static let jsScripts: [Int: JSScript] = {
        bundle.resource(.jsScripts)
    }()
    
    /// Dictionary of json values with keys as id
    private static let jsonValues: [Int: JSONValue] = {
        bundle.resource(.jsonValues)
    }()
    
    /// Returns the JSScript in `jsScripts` at key `id`
    static subscript(scriptID id: Int) -> JSScript {
        jsScripts[id, default: ""]
    }
    
    /// Returns the JSONValue in `jsonValues` at key `id`
    static subscript(jsonID id: Int) -> JSONValue {
        jsonValues[id, default: ""]
    }
}

/// JSScript conformance to ExpressibleByIntegerLiteral
extension JSScript: ExpressibleByIntegerLiteral {
    /// Initializes a JSScript instance from the id stored in `js-convert-scripts.json`
    public init(integerLiteral value: Int) {
        self = Resources[scriptID: value]
    }
}

/// JSONValue conformance to ExpressibleByIntegerLiteral
extension JSONValue: ExpressibleByIntegerLiteral {
    /// Initializes a JSONValue instance from the id stored in `json-values.json`
    public init(integerLiteral value: Int) {
        self = Resources[jsonID: value]
    }
}
