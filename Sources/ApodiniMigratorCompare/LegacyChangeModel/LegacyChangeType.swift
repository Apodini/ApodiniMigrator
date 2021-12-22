//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Distinct cases of change types that can appear in the Migration Guide
public enum LegacyChangeType: String, Value {
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
