//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigratorCore
import ApodiniMigratorClientSupport

struct JSScriptBuilder {
    private let from: TypeInformation
    private let to: TypeInformation
    private let changes: ChangeContextNode
    private let encoderConfiguration: EncoderConfiguration
    /// JScript converting from to to
    var convertFromTo: JSScript = ""
    /// JScript converting to to from
    var convertToFrom: JSScript = ""
    /// Textual hint to be used in the change object if the convertion is not reliable
    var hint: String?
    
    init(
        from: TypeInformation,
        to: TypeInformation,
        changes: ChangeContextNode = .init(),
        encoderConfiguration: EncoderConfiguration = .default
    ) {
        self.from = from
        self.to = to
        self.changes = changes
        self.encoderConfiguration = encoderConfiguration
        
        construct()
    }
    
    private mutating func construct() {
        let currentFrom = changes.currentVersion(of: from)
        if case let .scalar(fromPrimitive) = currentFrom, case let .scalar(toPrimitive) = to {
            let primitiveScript = JSPrimitiveScript.script(from: fromPrimitive, to: toPrimitive)
            convertFromTo = primitiveScript.convertFromTo
            convertToFrom = primitiveScript.convertToFrom
        } else {
            if currentFrom.isObject, to.isObject {
                let objectScript = JSObjectScript(from: currentFrom, to: to, changes: changes, encoderConfiguration: encoderConfiguration)
                convertFromTo = objectScript.convertFromTo
                convertToFrom = objectScript.convertToFrom
            } else {
                // swiftlint:disable:next line_length
                hint = "'ApodiniMigrator' is not able to automatically generate convert scripts between two types with different cardinalities or root types. Convert methods must be provided by the developer of the web service. Otherwise, the respective types in the client applications that will consume this Migration Guide, will be initialized with these default scripts."
                convertFromTo = Self.stringify(
                    argumentName: "ignoredFrom",
                    with: JSONStringBuilder.jsonString(to, with: encoderConfiguration)
                )
                convertToFrom = Self.stringify(
                    argumentName: "ignoredTo",
                    with: JSONStringBuilder.jsonString(currentFrom, with: encoderConfiguration)
                )
            }
        }
    }
    
    static func stringify(argumentName: String, with content: String) -> JSScript {
        .init(
        """
        function convert(\(argumentName)) {
            return JSON.stringify(\(content))
        }
        """
        )
    }
}
