//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Represents distinct cases of values that can appear in sections of Migration Guide, e.g. as default-values, fallback-values or identifiers
enum LegacyChangeValue: Decodable {
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
    
    /// A case where there is no need to provide an element, since the element is part of the old version and can be simply identified based on the `id`
    case elementID(DeltaIdentifier)
    
    /// A case to hold string values
    case stringValue(String)
    
    /// A case to hold json string representation of default values or fallback values of different types that can appear in the web service API,
    ///  and are subject to change. E.g. for a new added property of type User, the string of this case would be `{ "name": "", "id": 0 }`,
    ///  which can then be decoded in the client library accordingly
    case json(Int)
    
    /// Creates a new instance by decoding from the given decoder
    init(from decoder: Decoder) throws {
        do {
            let singleValueContainer = try decoder.singleValueContainer()
            let string = try singleValueContainer.decode(String.self)
            if string == "none" {
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
