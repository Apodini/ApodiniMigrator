//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

extension Array where Element: DeltaIdentifiable {
    func identifiers() -> [DeltaIdentifier] {
        map { $0.deltaIdentifier }
    }
}

extension Array where Element: DeltaIdentifiable & Hashable {
    func matchedIds(with other: Self) -> [DeltaIdentifier] {
        let ownIds = Set(identifiers())
        let otherIds = Set(other.identifiers())
        return ownIds.intersection(otherIds).asArray
    }
}

infix operator ?=
/// RelaxedDeltaIdentifiable protocol is an additional attempt to catch renamings of certain elements,
/// where the renameable element is used as `identifier` throughout the logic of the comparison. `RelaxedDeltaIdentifiable`
/// serves the purpose to not classify a rename as one addition and one removal.
/// Operation is always applied on compared elements that do not posses a matching `identifier` on different versions.
protocol RelaxedDeltaIdentifiable: DeltaIdentifiable {
    static func ?= (lhs: Self, rhs: Self) -> Bool
}

extension RelaxedDeltaIdentifiable {
    func mostSimilarWithSelf(in array: [Self], useRawValueDistance: Bool = true, similarityLimit: Double = 0.6) -> Self? {
        let mostSimilarId = array.compactMap { deltaIdentifiable -> (id: DeltaIdentifier, similarity: Double)? in
            let similarity = deltaIdentifier.rawValue.distance(between: deltaIdentifiable.deltaIdentifier.rawValue)
            return similarity <= similarityLimit ? nil : (id: deltaIdentifiable.deltaIdentifier, similarity: similarity)
        }.sorted { $0.similarity > $1.similarity }
        .first?.id
        
        return array.first(where: { (self ?= $0) && $0.deltaIdentifier == (useRawValueDistance ? mostSimilarId : $0.deltaIdentifier) })
    }
}

/// Endpoint extension to `RelaxedDeltaIdentifiable`
extension Endpoint: RelaxedDeltaIdentifiable {
    static func ?= (lhs: Endpoint, rhs: Endpoint) -> Bool {
        lhs.operation == rhs.operation && lhs.path == rhs.path
    }
}

/// Parameter extension to `RelaxedDeltaIdentifiable`
extension Parameter: RelaxedDeltaIdentifiable {
    static func ?= (lhs: Parameter, rhs: Parameter) -> Bool {
//        lhs.parameterType == rhs.parameterType
//            && lhs.typeInformation == rhs.typeInformation
//            && lhs.hasDefaultValue == rhs.hasDefaultValue
        
        
        /// TODO decide what makes sense as fallback identifier
        true
    }
}
