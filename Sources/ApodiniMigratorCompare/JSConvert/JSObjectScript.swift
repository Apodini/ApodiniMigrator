//
//  File.swift
//  
//
//  Created by Eldi Cano on 20.06.21.
//

import Foundation
import ApodiniMigrator

/// A util struct to hold matching properties between two types
private struct MatchedProperties: Hashable {
    /// Property of old type
    let from: TypeProperty
    /// Property of new type
    let to: TypeProperty
    
    func name(for type: PropertyType) -> String {
        type == .from ? from.name : to.name
    }
}

private enum PropertyType: String {
    case from = "From"
    case to = "To"
    
    var inversed: Self {
        self == .from ? .to : .from
    }
}

struct JSObjectScript { // TODO consider property renames for json string
    /// Old type
    private let from: TypeInformation
    /// NewType
    private let to: TypeInformation
    /// TypeRenames, additional attempt to increase the matching probability
    private let changes: ChangeContainer
    /// Properties of old type
    private let fromProperties: [TypeProperty]
    /// Properties of new type
    private let toProperties: [TypeProperty]
    /// Property holding the matched properties between types
    private var matchingProperties: Set<MatchedProperties> = []
    /// JScript converting from to to, property holds the convert function right after initialization of the instance
    private(set) var convertFromTo: JSScript = ""
    /// JScript converting to to from, property holds the convert function right after initialization of the instance
    private(set) var convertToFrom: JSScript = ""
    
    /// Initializer of a new instance
    init(from: TypeInformation, to: TypeInformation, changes: ChangeContainer = .init()) {
        self.from = from
        self.to = to
        self.changes = changes
        fromProperties = from.objectProperties
        toProperties = to.objectProperties
        
        construct()
    }
    
    private mutating func construct() {
        assignMatchingProperties()
        
        convertFromTo = script(forInputType: .from)
        convertToFrom = script(forInputType: .to)
    }
    
    private mutating func assignMatchingProperties() {
        for fromProperty in fromProperties {
            for toProperty in toProperties {
                process(fromProperty: fromProperty, toProperty: toProperty)
            }
        }
        
        for unmatchedFrom in unmatched(of: .from) {
            if let relaxedMatching = unmatchedFrom.mostSimilarWithSelf(in: unmatched(of: .to), limit: 0.7) {
                process(fromProperty: unmatchedFrom, toProperty: relaxedMatching, ignoreNames: true)
            }
        }
    }
    
    private mutating func process(fromProperty: TypeProperty, toProperty: TypeProperty, ignoreNames: Bool = false) {
        if propertyHasMatching(toProperty, type: .to), !fromProperty.type.sameType(with: toProperty.type) {
            return
        }
        // from here we now that the properties have the same cardinality, e.g. both optionals or both arrays...
        if fromProperty == toProperty { // name and the type is equal -> matching
            return addMatching(from: fromProperty, to: toProperty)
        }
        
        let namesEqual = fromProperty.name == toProperty.name || ignoreNames
        
        if namesEqual, fromProperty.type.typeName == toProperty.type.typeName { // same cardinality, same name, same typeName, e.g. (User, User)
            return addMatching(from: fromProperty, to: toProperty)
        }
        
        // same cardinality, same name, same renamed type (e.g. User, UserNew) -> matching
        if namesEqual, changes.typesAreRenamings(lhs: fromProperty.type, rhs: toProperty.type) {
            return addMatching(from: fromProperty, to: toProperty)
        }
    }
    
    private mutating func addMatching(from: TypeProperty, to: TypeProperty) {
        matchingProperties.insert(.init(from: from, to: to))
    }
    
    private func target(for type: PropertyType) -> [TypeProperty] {
        type == .from ? fromProperties : toProperties
    }
    
    private func unmatched(of propertyType: PropertyType) -> [TypeProperty] {
        target(for: propertyType).filter { property in
            !matchingProperties.contains(where: { (propertyType == .from ? $0.from : $0.to) == property })
        }
    }
    
    private mutating func propertyHasMatching(_ property: TypeProperty, type: PropertyType) -> Bool {
        !unmatched(of: type).contains(property)
    }
    
    private func matchings(of type: PropertyType) -> [MatchedProperties] {
        matchingProperties.filter { target(for: type).contains(type == .from ? $0.from : $0.to) }
    }
    
    private func keyValuePair(for property: TypeProperty, of type: PropertyType) -> String {
        let matchings = self.matchings(of: type)
        let matchedName = matchings.first(where: { (type == .from ? $0.from : $0.to) == property })?.name(for: type.inversed)
        let value: String = {
            if let matchedName = matchedName {
                return "parsed\(type.inversed.rawValue).\(matchedName)"
            }
            return JSONStringBuilder.jsonString(property.type, with: .default)
        }()
        return "\(property.name.singleQuoted): \(value)"
    }
    
    private func script(forInputType type: PropertyType) -> JSScript {
        let argumentName = type.rawValue.lowercased()
        let inversed = type.inversed
        let script =
        """
        function convert(\(argumentName)) {
            let parsed\(type.rawValue) = JSON.parse(\(argumentName))
            return JSON.stringify({\(target(for: inversed).map { "\(keyValuePair(for: $0, of: inversed))" }.joined(separator: ", "))})
        }
        """
        return .init(script)
    }
}
