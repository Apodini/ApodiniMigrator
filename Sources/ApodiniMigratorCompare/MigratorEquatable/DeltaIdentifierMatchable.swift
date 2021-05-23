//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

protocol DeltaIdentifierMatchable: DeltaIdentifiable {
    func matches(rhs: Self) -> Bool
}

extension DeltaIdentifierMatchable {
    func matches(rhs: Self) -> Bool {
        deltaIdentifier == rhs.deltaIdentifier
    }
}


extension Array where Element: DeltaIdentifierMatchable {
    func matchedIds(with other: Self) -> [DeltaIdentifier] {
        var ownIds = map { $0.deltaIdentifier }
        let otherIds = other.map { $0.deltaIdentifier }
        ownIds.append(contentsOf: otherIds)
        return ownIds.unique()
    }
}

extension Endpoint: DeltaIdentifierMatchable {}
extension Parameter: DeltaIdentifierMatchable {}

infix operator ?=

/// RelaxedDeltaIdentifierMatchable protocol is an additional attempt to catch renamings of certain elements,
/// where the renameable element is used as `identifier` throughout the logic of the comparison. `RelaxedDeltaIdentifierMatchable`
/// serves the purpose to not classify a rename as one addition and one removal.
/// Operation is always applied on compared elements that do not posses a matching `identifier` on different versions.
protocol RelaxedDeltaIdentifierMatchable {
    static func ?= (lhs: Self, rhs: Self) -> Bool
}

/// Endpoint extension to `RelaxedDeltaIdentifierMatchable`
extension Endpoint: RelaxedDeltaIdentifierMatchable {
    static func ?= (lhs: Endpoint, rhs: Endpoint) -> Bool {
        lhs.operation == rhs.operation && lhs.absolutePath == rhs.absolutePath
    }
}

extension Parameter: RelaxedDeltaIdentifierMatchable {
    static func ?= (lhs: Parameter, rhs: Parameter) -> Bool {
        lhs.parameterType == rhs.parameterType
            && lhs.typeInformation == rhs.typeInformation
            && lhs.hasDefaultValue == rhs.hasDefaultValue
    }
}
