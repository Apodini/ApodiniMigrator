//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

/// Represents the CodingKeys enum defined inside an object file
struct ObjectCodingKeys: SourceCodeRenderable {
    /// An enumeration `typeInformation` of the object, name is always `CodingKeys`
    private let codingKeysEnum: TypeInformation
    
    /// Cases of `codingKeysEnum`
    private var enumCases: [EnumCase] {
        codingKeysEnum.enumCases
    }
   
    /// Initializer of the coding keys from all properties of the object and potential renaming changes
    init(_ properties: [TypeProperty], renameChanges: [PropertyChange.IdentifierChange] = []) {
        let renameMap = renameChanges.reduce(into: [:]) { result, value in
            result[value.from.rawValue] = value.to.rawValue
        }
        
        let allCases: [EnumCase] = properties.map { property in
            let rawValue = renameMap[property.name] ?? property.name
            return .init(property.name, rawValue: rawValue)
        }
        
        codingKeysEnum = .enum(name: .init(rawValue: "CodingKeys"), rawValueType: .scalar(.string), cases: allCases.sorted(by: \.name))
    }
    
    /// Renders the content of the enum, in a non-formatted way
    var renderableContent: String {
        "private enum \(codingKeysEnum.typeName.mangledName): String, CodingKey {"
        Indent {
            for enumCase in enumCases {
                "case \(enumCase.name)\(enumCase.rawValue == enumCase.name ? "" : " = \"\(enumCase.rawValue)\"")"
            }
        }
        "}"
    }
}
