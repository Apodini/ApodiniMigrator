//
//  File.swift
//  
//
//  Created by Eldi Cano on 26.06.21.
//

import Foundation

/// A `ChangedParameter` holds properties of an endpoint `Parameter` from both versions.
struct ChangedParameter: Hashable {
    /// Name of the parameter in the previous version
    let oldName: String
    /// Name of the parameter in the new version, if name did not change, this property is equal to `oldName`
    let newName: String
    /// Kind of the parameter in the `new version`
    let kind: ParameterType
    /// Parameter necessity in the `old version`
    let necessity: Necessity
    /// Old type of the parameter
    let oldType: TypeInformation
    /// Type of the parameter in the new version, if type changed, `newType` is always `.reference`, from which the name of the type can be retrieved, otherwise equals `oldType`
    let newType: TypeInformation
    /// Id of the js script for converting old parameter type to the new type
    /// - Note: only one of the properties `convertFromTo` and `necessityValueJSONId` can be non-nil at the same type
    let convertFromTo: Int?
    /// Id of the default json value for if the parameter has been added in the new version,
    /// If the migration guide did not provide any defaul value for the added parameter due to optional necessity, this value is equal to `-1`
    let addedValueJSONId: Int?
    /// Id of the necessity value json id, if the necessity of the parameter changed from optional to required
    /// - Note: only one of the properties `convertFromTo` and `necessityValueJSONId` can be non-nil at the same type
    let necessityValueJSONId: Int?
    /// A flag to indicate whether the parameter has been `deleted` in the new version
    let deleted: Bool
    
    /// A convenience static function that returns an added `ChangedParameter` out of an `Parameter` of new version and a `jsonValueID`
    static func addedParameter(_ parameter: Parameter, jsonValueID: Int) -> ChangedParameter {
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
    
    /// A convenience static function that returns a deleted `ChangedParameter` out of an `Parameter` of old version
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
