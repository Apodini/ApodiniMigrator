//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public enum ParameterChangeTarget: String, Decodable {
    case necessity
    case kind
    case typeInformation = "type"
}

/// Represents an update change of an arbitrary element from some old value to some new value,
/// the most frequent change that can appear in the Migration guide. Depending on the change element
/// and the target, the type of an update change can either be a generic `.update` or a `.rename`, `.propertyChange`, `.parameterChange` or `.responseChange`,
/// which can be initialized through different initializers
struct LegacyUpdateChange: LegacyChange {
    // MARK: Private Inner Types
    enum CodingKeys: String, CodingKey {
        case element
        case type = "change-type"
        case parameterTarget = "parameter-target"
        case targetID = "target-id"
        case from
        case to
        case similarity = "similarity-score"
        case necessityValue = "necessity-value"
        case convertFromTo = "convert-from-to-script-id"
        case convertToFrom = "convert-to-from-script-id"
        case convertionWarning = "convertion-warning"
        case breaking
        case solvable
        case providerSupport = "provider-support"
    }
    
    /// Top-level changed element related to the change
    let element: LegacyChangeElement
    /// Type of change, can either be a generic `.update` or a `.rename`, `.propertyChange`, `.parameterChange` or `.responseChange`
    let type: LegacyChangeType
    /// Old value of the target
    let from: LegacyChangeValue
    /// New value of the target
    let to: LegacyChangeValue
    /// Similarity score from 0 to 1 for renaming
    let similarity: Double?
    /// Optional id of the target
    let targetID: DeltaIdentifier?
    /// A json id in case that the necessity of a property or a parameter changed
    let necessityValue: LegacyChangeValue?
    /// JS convert function to convert old type to new type
    let convertFromTo: Int?
    /// JS convert function to convert new type to old type, e.g. if the change element is an object and the target is property
    let convertToFrom: Int?
    /// Warning regarding the provided convert scripts
    let convertionWarning: String?
    /// The target of the parameter which is related to the change if type is a `parameterChange`
    let parameterTarget: ParameterChangeTarget?
    /// Indicates whether the change is non-backward compatible
    let breaking: Bool
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    let solvable: Bool
    /// Provider support field if change type is a rename and `compare-config` of the Migration Guide is set to `true` for `include-provider-support`
    let providerSupport: LegacyProviderSupport?
}
