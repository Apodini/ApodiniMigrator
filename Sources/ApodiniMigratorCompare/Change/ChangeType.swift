//
//  File.swift
//  
//
//  Created by Eldi Cano on 15.06.21.
//

import Foundation

/// Distinct cases of change types that can appear in the Migration Guide
public enum ChangeType: String, Value {
    /// An AddChange
    case addition
    /// A DeleteChange
    case deletion
    /// An update change where `from` and `to` properties are `.stringValue`
    case rename
    /// An udpate change
    case update
    /// A change related to an endpoint parameter
    case parameterChange = "parameter-change"
    /// A change related to a property of an object
    case propertyChange = "property-change"
    /// An unsupported change by `ApodiniMigrator`
    case unsupported
}
