//
//  File.swift
//  
//
//  Created by Eldi Cano on 20.06.21.
//

import Foundation
import ApodiniMigrator
import ApodiniMigratorClientSupport

struct JSScriptBuilder { /// TODO add new jsonstring builder that considers renamings, additions and deletion of properties
    private let from: TypeInformation
    private let to: TypeInformation
    private let changes: ChangeContainer
    private let encoderConfiguration: EncoderConfiguration
    /// JScript converting from to to
    var convertFromTo: JSScript = ""
    /// JScript converting to to from
    var convertToFrom: JSScript = ""
    /// Textual hint to be used in the change object if the convertion is not reliable
    var hint: String? = nil
    
    init(
        from: TypeInformation,
        to: TypeInformation,
        changes: ChangeContainer = .init(),
        encoderConfiguration: EncoderConfiguration = .default
    ) {
        self.from = from
        self.to = to
        self.changes = changes
        self.encoderConfiguration = encoderConfiguration
        
        construct()
    }
    
    private mutating func construct() {
        if case let .scalar(fromPrimitive) = from, case let .scalar(toPrimitive) = to {
            let primitiveScript = JSPrimitiveScript.script(from: fromPrimitive, to: toPrimitive)
            convertFromTo = primitiveScript.convertFromTo
            convertToFrom = primitiveScript.convertToFrom
        } else if from.isObject, to.isObject {
            let objectScript = JSObjectScript(from: from, to: to, changes: changes, encoderConfiguration: encoderConfiguration)
            convertFromTo = objectScript.convertFromTo
            convertToFrom = objectScript.convertToFrom
        } else {
            // swiftlint:disable:next line_length
            hint = "'ApodiniMigrator' is not able to automatically generate convert scripts between two types with different cardinalities or root types. Convert methods must be provided by the developer of the web service. Otherwise, the respective types in the client applications that will consume this Migration Guide, will be initialized with these default scripts."
            convertFromTo = Self.stringify(argumentName: "ignoredFrom", with: JSONStringBuilder.jsonString(to, with: encoderConfiguration))
            convertToFrom = Self.stringify(argumentName: "ignoredTo", with: JSONStringBuilder.jsonString(from, with: encoderConfiguration))
        }
    }
    
    static func stringify(argumentName: String, with content: String) -> JSScript {
        .init("""
        function convert(\(argumentName)) {
            return JSON.stringify(\(content))
        }
        """)
    }
}
