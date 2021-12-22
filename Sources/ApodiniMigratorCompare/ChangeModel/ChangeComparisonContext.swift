//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

final class ChangeComparisonContext {
    /// The configuration used when comparing two `APIDocument`s.
    let configuration: CompareConfiguration
    /// This array contains all model definition of the update API document.
    let latestModels: [TypeInformation]

    /// All javascript convert methods created during comparison
    var scripts: [Int: JSScript] = [:]
    /// All json values of properties or parameter that require a default or fallback value
    var jsonValues: [Int: JSONValue] = [:]
    /// All json representations of objects that had some kind of breaking change in their properties
    private(set) var objectJSONs: [String: JSONValue] = [:]

    var serviceChanges: [ServiceInformationChange] = []
    var modelChanges: [ModelChange] = []
    var endpointChanges: [EndpointChange] = []

    init(configuration: CompareConfiguration? = nil, latestModels: [TypeInformation] = []) {
        self.configuration = configuration ?? .default
        self.latestModels = latestModels
    }


    /// Stores the script and returns its stored index
    func store(script: JSScript) -> Int {
        let count = scripts.count
        scripts[count] = script
        return count
    }

    /// Stores the jsonValue and returns stored index
    func store(jsonValue: JSONValue) -> Int {
        let count = jsonValues.count
        jsonValues[count] = jsonValue
        return count
    }
}

// MARK: JSScript Support
extension ChangeComparisonContext {
    func currentVersion(of lhs: TypeInformation) -> TypeInformation {
        switch lhs {
        case .scalar:
            return lhs
        case let .repeated(element):
            return .repeated(element: currentVersion(of: element))
        case let .dictionary(key, value):
            return .dictionary(key: key, value: currentVersion(of: value))
        case let .optional(wrappedValue):
            return .optional(wrappedValue: wrappedValue)
        case .enum, .object:
            return latestModels.first(where: { $0.deltaIdentifier == lhs.deltaIdentifier })
                    ?? lhs
        case .reference:
            fatalError("Encountered a reference in `\(Self.self)`")
        }
    }

    // TODO evaluate placement! (same for above)
    func isPairOfRenamedTypes(lhs: TypeInformation, rhs: TypeInformation) -> Bool {
        if !configuration.allowTypeRename {
            return false
        }

        return modelChanges.contains(where: { change in
            if case let .idChange(from, to, _, _, _) = change {
                return from == lhs.deltaIdentifier && to == rhs.deltaIdentifier
            }
            return false
        })
    }

    /*
     func sameNestedTypes(lhs: TypeInformation, rhs: TypeInformation) -> Bool {
        if lhs.typeName.name == rhs.typeName.name {
            return true
        }
        return allowTypeRename ? changes.typesAreRenamings(lhs: lhs, rhs: rhs) : false
    }

    func typesNeedConvert(lhs: TypeInformation, rhs: TypeInformation) -> Bool {
        let sameNestedType = sameNestedTypes(lhs: lhs, rhs: rhs)
        return (sameNestedType && !lhs.sameType(with: rhs)) || !sameNestedType
    }
     */

    /// For every compare between two models of different versions, this function is called to register potentially updated json representation of an object
    func store(rhs: TypeInformation) {
        // TODO
        //  let propertyTargets = [ObjectTarget.property, .necessity].map { $0.rawValue }
        //  $0.breaking
        //                && $0.element.isObject
        //                && $0.elementID == rhs.deltaIdentifier
        //                && propertyTargets.contains($0.element.target)

        // if in natural language: if the list of model changes contains
        //  an property change of an object where the identifier matches with "rhs" and the change is breaking
        if modelChanges.contains(where: { change in
            if case let .update(id, update, breaking, _) = change,
                breaking,
                id == rhs.deltaIdentifier,
                case .property = update {
                return true
            }
            return false
        }) {
            // TODO name index! what was the intention here?
            objectJSONs[rhs.typeName.mangledName] = .init(JSONStringBuilder.jsonString(rhs, with: configuration.encoderConfiguration))
        }
    }
}
