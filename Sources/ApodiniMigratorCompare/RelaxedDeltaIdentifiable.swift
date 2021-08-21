//
//  RelaxedDeltaIdentifiable.swift
//  ApodiniMigratorCompare
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

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

private struct DeltaSimilarity: Comparable {
    let similarity: Double
    let identifier: DeltaIdentifier
    
    static func < (lhs: DeltaSimilarity, rhs: DeltaSimilarity) -> Bool {
        lhs.similarity < rhs.similarity
    }
}

extension DeltaIdentifier {
    func distance(between other: DeltaIdentifier) -> Double {
        rawValue.distance(between: other.rawValue)
    }
}

extension RelaxedDeltaIdentifiable {
    func mostSimilarWithSelf(in array: [Self], useRawValueDistance: Bool = true, limit: Double = 0.5) -> (similarity: Double?, element: Self)? {
        let similarity = array.compactMap { deltaIdentifiable -> DeltaSimilarity? in
            let currentId = deltaIdentifiable.deltaIdentifier
            let similarity = deltaIdentifier.distance(between: currentId)
            return similarity < limit ? nil : DeltaSimilarity(similarity: similarity, identifier: currentId)
        }
        .max()
        if let matched = array.first(where: { (self ?= $0) && $0.deltaIdentifier == (useRawValueDistance ? similarity?.identifier : $0.deltaIdentifier) }) {
            return (similarity?.similarity, matched)
        }
        return nil
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
        true
    }
}

extension EnumCase: RelaxedDeltaIdentifiable {
    static func ?= (lhs: EnumCase, rhs: EnumCase) -> Bool {
        true
    }
}

extension TypeProperty: RelaxedDeltaIdentifiable {
    static func ?= (lhs: TypeProperty, rhs: TypeProperty) -> Bool {
        true
    }
}

extension TypeName: RelaxedDeltaIdentifiable {
    static func ?= (lhs: TypeName, rhs: TypeName) -> Bool {
        if lhs == rhs {
            return true
        }
        
        let primitiveTypeNames = PrimitiveType.allCases.map { $0.typeName }
        let lhsIsPrimitive = primitiveTypeNames.contains(lhs)
        let rhsIsPrimitive = primitiveTypeNames.contains(rhs)
        
        // if not already equal in the first check, we are dealing with two different primitive types, e.g. Bool and Int
        if lhsIsPrimitive && rhsIsPrimitive {
            return false
        }
        
        // If one is primitive and the other one not, returning false, otherwise string similarity of
        // complex type names to ensure that we are dealing with a rename
        return lhsIsPrimitive != rhsIsPrimitive ? false : lhs.deltaIdentifier.distance(between: rhs.deltaIdentifier) > 0.5
    }
}

extension TypeInformation: DeltaIdentifiable {
    public var deltaIdentifier: DeltaIdentifier {
        if case let .reference(key) = self {
            return .init(key.rawValue)
        }
        return typeName.deltaIdentifier
    }
}

extension TypeInformation: RelaxedDeltaIdentifiable {
    static func ?= (lhs: TypeInformation, rhs: TypeInformation) -> Bool {
        lhs.typeName ?= rhs.typeName
    }
}
