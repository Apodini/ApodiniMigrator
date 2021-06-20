//
//  File.swift
//  
//
//  Created by Eldi Cano on 20.06.21.
//

import Foundation
import ApodiniMigrator

struct JSScriptBuilder {
    private let from: TypeInformation
    private let to: TypeInformation
    private let changes: ChangeContainer
    /// JScript converting from to to
    var convertFromTo: JSScript = ""
    /// JScript converting to to from
    var convertToFrom: JSScript = ""
    
    init(from: TypeInformation, to: TypeInformation, changes: ChangeContainer) {
        self.from = from
        self.to = to
        self.changes = changes
        
        construct()
    }
    
    private mutating func construct() {
        if case let .scalar(fromPrimitive) = from, case let .scalar(toPrimitive) = to {
            let primitiveScript = JSPrimitiveScript.script(from: fromPrimitive, to: toPrimitive)
            convertFromTo = primitiveScript.convertFromTo
            convertToFrom = primitiveScript.convertToFrom
        } else if from.isObject, to.isObject {
            let objectScript = JSObjectScript(from: from, to: to, changes: changes)
            convertFromTo = objectScript.convertFromTo
            convertToFrom = objectScript.convertToFrom
        } else if from.isEnum, to.isEnum {
            let message = JSScript(
                """
                'ApodiniMigrator' is not able to automatically generate convert scripts between two enumerations. Convert methods must be provided
                by the developer of the web service. Otherwise, the enumerations in the client applications that will consume this Migration Guide,
                will be always initialized with a random case.
                """
                )
            convertFromTo = message
            convertToFrom = message
        } else {
            let message = JSScript(
                """
                'ApodiniMigrator' is not able to automatically generate convert scripts between two types with different cardinalities.
                Convert methods must be provided by the developer of the web service. Otherwise, the respective types in the client applications
                that will consume this Migration Guide, will be initialized with empty values.
                """
                )
            convertFromTo = message
            convertToFrom = message
        }
    }
}
