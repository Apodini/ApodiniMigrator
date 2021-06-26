//
//  File.swift
//  
//
//  Created by Eldi Cano on 26.06.21.
//

import Foundation

struct ChangedParameter: Hashable {
    let oldName: String
    let newName: String
    let kind: ParameterType
    let necessity: Necessity
    let oldType: TypeInformation
    let newType: TypeInformation
    let convertFromTo: Int?
    let addedValueJSONId: Int?
    let necessityValueJSONId: Int?
    let deleted: Bool
    
    static func addedParameter(_ parameter: Parameter, jsonValueID: Int?) -> ChangedParameter {
        .init(
            oldName: parameter.name,
            newName: parameter.name,
            kind: parameter.parameterType,
            necessity: parameter.necessity,
            oldType: parameter.typeInformation,
            newType: parameter.typeInformation,
            convertFromTo: nil,
            addedValueJSONId: jsonValueID,
            necessityValueJSONId: nil,
            deleted: false
        )
    }
    
    static func deletedParameter(_ parameter: Parameter) -> ChangedParameter {
        .init(
            oldName: parameter.name,
            newName: parameter.name,
            kind: parameter.parameterType,
            necessity: parameter.necessity,
            oldType: parameter.typeInformation,
            newType: parameter.typeInformation,
            convertFromTo: nil,
            addedValueJSONId: nil,
            necessityValueJSONId: nil,
            deleted: true
        )
    }
}
