//
//  ChangeType.swift
//  ApodiniMigratorCompare
//
//  Created by Eldi Cano on 27.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Distinct cases of change types that can appear in the Migration Guide
public enum ChangeType: String, Value {
    /// An AddChange
    case addition
    /// A DeleteChange
    case deletion
    
    /// An update change
    case update = "value-update"
    /// An update change where `from` and `to` properties are `.stringValue`
    case rename
    /// An update change related to the response of an endpoint
    case responseChange = "response-change"
    /// An update change related to a property of an object
    case propertyChange = "property-change"
    /// A change related to an endpoint parameter
    case parameterChange = "parameter-change"
    
    /// An unsupported change by `ApodiniMigrator`
    case unsupported
}
