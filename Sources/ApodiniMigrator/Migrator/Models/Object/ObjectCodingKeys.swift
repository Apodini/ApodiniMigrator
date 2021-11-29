//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import MigratorAPI

/// Represents the CodingKeys enum defined inside an object file
struct ObjectCodingKeys: RenderableBuilder {
    /// An enumeration `typeInformation` of the object, name is always `CodingKeys`
    private let codingKeysEnum: TypeInformation
    
    /// Cases of `codingKeysEnum`
    private var enumCases: [EnumCase] {
        codingKeysEnum.enumCases
    }
   
    /// Initializer of the coding keys from all properties of the object and potential renaming changes
    init(_ properties: [TypeProperty], renameChanges: [UpdateChange] = []) {
        let renames = renameChanges.reduce(into: [String: String]()) { result, current in
            if case let .stringValue(oldName) = current.from, case let .stringValue(newName) = current.to {
                result[oldName] = newName
            }
        }
        
        let allCases: [EnumCase] = properties.map { property in
            let rawValue = renames[property.name] ?? property.name
            return .init(property.name, rawValue: rawValue)
        }
        
        codingKeysEnum = .enum(name: .init(name: "CodingKeys"), rawValueType: .scalar(.string), cases: allCases.sorted(by: \.name))
    }
    
    /// Renders the content of the enum, in a non-formatted way
    var fileContent: String {
        "private enum \(codingKeysEnum.typeName.name): String, CodingKey {"
        Indent {
            for enumCase in enumCases {
                "case \(enumCase.name)\(enumCase.rawValue == enumCase.name ? "" : " = \"\(enumCase.rawValue)\"")"
            }
        }
        "}"
    }
}
