//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Represents distinct cases of values that can appear in sections of Migration Guide, e.g. as default-values, fallback-values or identifiers
public enum ChangeValue: Value {
    private enum ChangeValueCodingError: Error {
        case notNone
    }
    
    // MARK: Private Inner Types
    enum CodingKeys: String, CodingKey {
        case element, elementID = "element-id", stringValue = "string-value", json = "json-value-id"
    }
    
    /// Not all changed elements need to provide a value. This case serves those scenarios (this case is decoded in a singleValueContainer)
    case none
    
    /// Holds a type-erasured codable element of one of the models of `ApodiniMigrator` that are subject to change
    case element(AnyCodableElement)
    /// An internal convenience method to initialize `.element` case ouf of an `AnyCodableElementValue`
    static func element<A: AnyCodableElementValue>(_ element: A) -> ChangeValue {
        .element(element.asAnyCodableElement)
    }
    
    /// A case where there is no need to provide an element, since the element is part of the old version and can be simply identified based on the `id`
    case elementID(DeltaIdentifier)
    /// An internal convenience method to initialize `.elementID` case ouf of an `DeltaIdentifiable`
    static func id<D: DeltaIdentifiable>(from identifiable: D) -> ChangeValue {
        .elementID(identifiable.deltaIdentifier)
    }
    
    /// A case to hold string values
    case stringValue(String)
    
    /// A case to hold json string representation of default values or fallback values of different types that can appear in the web service API,
    ///  and are subject to change. E.g. for a new added property of type User, the string of this case would be `{ "name": "", "id": 0 }`,
    ///  which can then be decoded in the client library accordingly
    case json(Int)
    /*
     TODO remove
    /// An internal convenience method to initalize `.json` case from the typeInformation of the type
    /// Encoder configuration is passed from the new version in order to encode the default values with the correct encoder configuration
    static func value(from typeInformation: TypeInformation, with configuration: EncoderConfiguration, changes: ChangeContextNode) -> ChangeValue {
        let jsonValue = JSONValue(JSONStringBuilder.jsonString(typeInformation, with: configuration))
        return .json(changes.store(jsonValue: jsonValue))
    }
    */
    
    /// Returns the nested string value of the cases, or `nil` if `self` is `.element`
    public var value: String? {
        switch self {
        case .none: return "none"
        case let .elementID(id): return id.rawValue
        case let .stringValue(string): return string
        case let .json(id): return "\(id)"
        default: return nil
        }
    }
    
    /// Encodes `self` into the given encoder
    public func encode(to encoder: Encoder) throws {
        if case .none = self, let value = value {
            var singleValueContainer = encoder.singleValueContainer()
            return try singleValueContainer.encode(value)
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if case let .element(element) = self {
            return try container.encode(element, forKey: .element)
        }
        
        var key: CodingKeys?
        switch self {
        case .elementID: key = .elementID
        case .stringValue: key = .stringValue
        case .json: key = .json
        default: break
        }
        
        guard let codingKey = key else {
            throw EncodingError.invalidValue((), EncodingError.Context(codingPath: [], debugDescription: "\(Self.self) did not encode any value"))
        }
        
        if codingKey == .json {
            return try container.encode(Int(value ?? ""), forKey: codingKey)
        }
        
        try container.encode(value, forKey: codingKey)
    }
    
    /// Creates a new instance by decoding from the given decoder
    public init(from decoder: Decoder) throws {
        do {
            let singleValueContainer = try decoder.singleValueContainer()
            let string = try singleValueContainer.decode(String.self)
            if string == ChangeValue.none.value {
                self = .none
            } else {
                throw ChangeValueCodingError.notNone
            }
        } catch {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            guard let key = container.allKeys.first else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Failed to decode \(Self.self)"))
            }
            
            switch key {
            case .element: self = .element(try container.decode(AnyCodableElement.self, forKey: .element))
            case .elementID: self = .elementID(try container.decode(DeltaIdentifier.self, forKey: .elementID))
            case .stringValue: self = .stringValue(try container.decode(String.self, forKey: .stringValue))
            case .json: self = .json(try container.decode(Int.self, forKey: .json))
            }
        }
    }
}
