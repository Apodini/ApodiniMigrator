//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A `MigratedParameter` holds properties of an endpoint `Parameter` from both versions based on the changes specified in the migration guide
struct MigratedParameter: Hashable {
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
    /// If the migration guide did not provide any default value for the added parameter due to optional necessity, this value is equal to `-1`
    let defaultValue: Int?
    /// Id of the necessity value json id, if the necessity of the parameter changed from optional to required
    /// - Note: only one of the properties `convertFromTo` and `necessityValueJSONId` can be non-nil at the same type
    let necessityValueJSONId: Int?
    /// A flag to indicate whether the parameter has been `deleted` in the new version
    let deleted: Bool
    
    /// A convenience static function that returns an added `MigratedParameter` out of an `Parameter` of new version and a `jsonValueID`
    static func addedParameter(_ parameter: Parameter, defaultValue: Int?) -> MigratedParameter {
        .init(
            oldName: parameter.name,
            newName: parameter.name,
            kind: parameter.parameterType,
            necessity: parameter.necessity,
            oldType: parameter.typeInformation,
            newType: parameter.typeInformation,
            convertFromTo: nil,
            defaultValue: defaultValue,
            necessityValueJSONId: nil,
            deleted: false
        )
    }
    
    /// A convenience static function that returns a deleted `MigratedParameter` out of an `Parameter` of old version
    static func deletedParameter(_ parameter: Parameter) -> MigratedParameter {
        .init(
            oldName: parameter.name,
            newName: parameter.name,
            kind: parameter.parameterType,
            necessity: parameter.necessity,
            oldType: parameter.typeInformation,
            newType: parameter.typeInformation,
            convertFromTo: nil,
            defaultValue: nil,
            necessityValueJSONId: nil,
            deleted: true
        )
    }
}
