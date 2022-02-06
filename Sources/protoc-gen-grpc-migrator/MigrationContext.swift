//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

extension TypeInformationIdentifiers: TypeIdentifiersDescription {}

struct MigrationContext {
    // TODO save previous package name etc?
    let exporterConfiguration: GRPCExporterConfiguration
    /// The base `APIDocument`
    let document: APIDocument
    /// The `MigrationGuide`
    private(set) var migrationGuide: MigrationGuide
    /// This is a custom TypeStore we maintain which combines the `TypeStore` from the `APIDocument`
    /// and all types which are newly introduced via the `MigrationGuide`.
    /// This TypeStore also contains the wrapper types created through the `ParameterCombination`.
    let typeStore: TypesStore
    /// Array of `TypeInformation` of Endpoint Parameter wrapper types which were newly and dynamically created
    /// AND got added to the `APIDocument` `TypeStore` (wrapper types derive from ADDED endpoints are stored
    /// as model additions in the MigrationGuide).
    /// The MigrationGuide might contain **property changes** for those models.
    /// NOTE: Those models are guaranteed to be **dereferenced**!
    let apiDocumentModelAdditions: [TypeInformation]

    init(document: APIDocument, migrationGuide: MigrationGuide) {
        let lhsConfiguration = document.serviceInformation.exporter(for: GRPCExporterConfiguration.self)
        let rhsConfiguration = document.serviceInformation.exporter(for: GRPCExporterConfiguration.self, migrationGuide: migrationGuide)

        // TODO handle empty parameters!

        var document = document
        var migrationGuide = migrationGuide

        // We have the following problem: with the ParameterCombination new types get added to two different places:
        // (1) the APIDocument TypeStore and (2) to the MigrationGuide through Model addition changes.
        // As our library basis is not based on the `APIDocument` but on the proto files, we need to uncover
        // which values got added to the `TypeStore` such that we can manually add it to our generated files.
        // To do this, we track the current `TypeStore` state with the means of `DeltaIdentifier`.
        let typeStoreState = Set(document.models.map { $0.deltaIdentifier })

        let combination = GRPCMethodParameterCombination(typeStore: document.typeStore)
        document.combineEndpointParametersIntoWrappedType(
            considering: &migrationGuide,
            using: combination
        )

        // Based on `typeStoreState` we derive which models got added via the ParameterCombination
        var apiDocumentModelAdditions: [TypeInformation] = []
        for model in document.models where !typeStoreState.contains(model.deltaIdentifier) {
            apiDocumentModelAdditions.append(model)
        }

        // it is important that we pull out the typeStore only after the `ParameterCombination` has run.
        // Above operation will store new types (only for the endpoints which are part of the APIDocument)
        // which will be stored there. Endpoint Parameter will have reference type.
        var typeStore = document.typeStore

        // Now we add all the newly introduced types contained in the migration guide to the custom maintained `TypeStore`.
        // This is important as e.g. newly added Endpoints will contain reference types which we need to resolved!
        for change in migrationGuide.modelChanges {
            guard let addition = change.modeledAdditionChange else {
                continue
            }

            _ = typeStore.store(addition.added)
        }

        self.exporterConfiguration = rhsConfiguration
        self.document = document
        self.migrationGuide = migrationGuide
        self.typeStore = typeStore
        self.apiDocumentModelAdditions = apiDocumentModelAdditions

        computeIdentifiersOfSynthesizedEndpointTypes(lhs: lhsConfiguration, rhs: rhsConfiguration)
    }

    private mutating func computeIdentifiersOfSynthesizedEndpointTypes(
        lhs lhsConfiguration: GRPCExporterConfiguration,
        rhs rhsConfiguration: GRPCExporterConfiguration
    ) {
        for endpoint in document.endpoints {
            let swiftTypeName = endpoint.swiftTypeName
            let updatedSwiftTypeName = endpoint.updatedSwiftTypeName(considering: migrationGuide)

            guard let lhsIdentifiers = lhsConfiguration.identifiersOfSynthesizedTypes[swiftTypeName] else {
                continue // happens when neither input nor output type of an endpoint is synthesized
            }

            // we have the base type which didn't change, which we augment with the base identifiers
            _augmentIdentifiersOfSynthesizedTypes(of: endpoint, with: lhsIdentifiers)

            guard let rhsIdentifiers = rhsConfiguration.identifiersOfSynthesizedTypes[updatedSwiftTypeName] else {
                continue // endpoint (and its types) were probably removed in latest version (or aren't synthesized anymore)
            }

            // additionally we need to check for the following:
            // - added properties
            // - updated identifiers (grpc number or field type)
            // - As we match children via their property name, we need to check if anything got renamed!

            var modelChanges: [ModelChange] = []

            if lhsIdentifiers.inputIdentifiers != nil || rhsIdentifiers.inputIdentifiers != nil {
                let lhsInputIdentifiers = lhsIdentifiers.inputIdentifiers ?? TypeInformationIdentifiers()
                let rhsInputIdentifiers = rhsIdentifiers.inputIdentifiers ?? TypeInformationIdentifiers()

                // TODO we can enforce that the base type isn't wrapped or anything right?
                //  => it could be optional
                precondition(endpoint.parameters.count == 1, "Unexpected endpoint count for \(endpoint)")
                let parameter = endpoint.parameters[0]

                computeIdentifiersOfSynthesizedType(
                    of: parameter.typeInformation,
                    lhs: lhsInputIdentifiers,
                    rhs: rhsInputIdentifiers,
                    collectInto: &modelChanges
                )
            }

            if lhsIdentifiers.outputIdentifiers != nil || rhsIdentifiers.outputIdentifiers != nil {
                let lhsOutputIdentifiers = lhsIdentifiers.outputIdentifiers ?? TypeInformationIdentifiers()
                let rhsOutputIdentifiers = rhsIdentifiers.outputIdentifiers ?? TypeInformationIdentifiers()
                // TODO for the response wrapper! we need to consider (and map) endpoint updates (optionals and arrays and stuff)!
                computeIdentifiersOfSynthesizedType(
                    of: endpoint.response,
                    lhs: lhsOutputIdentifiers,
                    rhs: rhsOutputIdentifiers,
                    collectInto: &modelChanges
                )
            }

            for change in modelChanges {
                migrationGuide.modelChanges.append(change)
            }
        }

        for change in migrationGuide.endpointChanges {
            guard let addedEndpoint = change.modeledAdditionChange,
                  let identifiers = rhsConfiguration.identifiersOfSynthesizedTypes[addedEndpoint.added.swiftTypeName] else {
                // either not an added endpoint or added endpoint doesn't have any synthesized types!
                continue
            }

            var endpoint = addedEndpoint.added
            endpoint.dereference(in: typeStore)

            _augmentIdentifiersOfSynthesizedTypes(of: endpoint, with: identifiers)
        }
    }

    private mutating func computeIdentifiersOfSynthesizedType(
        of typeInformation: TypeInformation,
        lhs lhsIdentifiers: TypeInformationIdentifiers,
        rhs rhsIdentifiers: TypeInformationIdentifiers,
        collectInto modelChanges: inout [ModelChange]
    ) {
        // Step 1: compare the identifier storage of the type itself
        var rootIdentifierChanges: [ElementIdentifierChange] = []
        let rootComparator = ElementIdentifiersComparator(
            lhs: Array(lhsIdentifiers.identifiers.values),
            rhs: Array(rhsIdentifiers.identifiers.values)
        )
        rootComparator.compare(&rootIdentifierChanges)

        for change in rootIdentifierChanges {
            migrationGuide.modelChanges.append(.update(
                id: typeInformation.deltaIdentifier,
                updated: .identifier(identifier: change),
                breaking: change.breaking,
                solvable: change.solvable
            ))
        }

        // Step 2: compare the identifier storage of the type children
        switch typeInformation.unwrapped {
        case let .object(_, properties, _):
            let propertyChanges: [PropertyChange] = migrationGuide.modelChanges.compactMap { change in
                guard change.id == typeInformation.deltaIdentifier,
                      let updateChange = change.modeledUpdateChange,
                      case let .property(propertyChange) = updateChange.updated else {
                    return nil
                }
                return propertyChange
            }

            let modelChanges = computeIdentifiersOfSynthesizedTypeChildren(
                parent: typeInformation.deltaIdentifier,
                children: properties,
                changes: propertyChanges,
                lhsIdentifiers: lhsIdentifiers,
                rhsIdentifiers: rhsIdentifiers
            )

            migrationGuide.modelChanges.append(contentsOf: modelChanges)
        case .enum:
            preconditionFailure("Some assumption broke. Encountered synthesized wrapper type which is a enum. Expected a object: \(typeInformation)")
        default:
            // arrays are never created for endpoint types?
            break // TODO remove this again, happens as output types aren't wrapped yet!
            fatalError("Encountered unexpected typeInformation model \(typeInformation) when computing changes of synthesized type children")
        }
    }

    private func computeIdentifiersOfSynthesizedTypeChildren(
        parent typeId: DeltaIdentifier,
        children: [TypeProperty],
        changes: [PropertyChange],
        lhsIdentifiers: TypeInformationIdentifiers,
        rhsIdentifiers: TypeInformationIdentifiers
    ) -> [ModelChange] {
        // in order to compare updated children identifiers,
        // we need to collect the update names to properly match them together.
        var childrenNameMapping: [DeltaIdentifier: DeltaIdentifier] = [:]
        // further we collect the removed children to know where we don't need to expect updated identifiers.
        var removedChildren: Set<DeltaIdentifier> = []

        for change in changes {
            if let additionChange = change.modeledAdditionChange {
                let addedChild = additionChange.added

                guard let storage = rhsIdentifiers.childrenIdentifiers[addedChild.name] else {
                    continue
                }

                addedChild.context.unsafeAdd(TypeInformationIdentifierContextKey.self, value: storage)
            } else if let renameChange = change.modeledIdentifierChange {
                childrenNameMapping[renameChange.from] = renameChange.to
            } else if let removalChange = change.modeledRemovalChange {
                removedChildren.insert(removalChange.id)
            }
        }

        var childrenChanges: [PropertyChange] = []

        for child in children {
            guard !removedChildren.contains(child.deltaIdentifier) else {
                continue
            }

            let updatedName = childrenNameMapping[child.deltaIdentifier] ?? child.deltaIdentifier

            // TODO it is guaranteed that at least one thing exists (e.g. to analyze removed or added identifiers?)
            //  -> should we assert existence at all? => robustness in the future to add or remove identifiers?
            guard let lhsStorage = lhsIdentifiers.childrenIdentifiers[child.name],
                  let rhsStorage = rhsIdentifiers.childrenIdentifiers[updatedName.rawValue]  else {
                fatalError("Found property for which we couldn't find matching identifier storage \(child) in '\(typeId.rawValue)'")
            }

            var identifierChanges: [ElementIdentifierChange] = []
            let comparator = ElementIdentifiersComparator(
                lhs: Array(lhsStorage.values),
                rhs: Array(rhsStorage.values)
            )
            comparator.compare(&identifierChanges)

            childrenChanges.append(contentsOf: identifierChanges.map { change in
                .update(
                    id: child.deltaIdentifier,
                    updated: .identifier(identifier: change),
                    breaking: change.breaking,
                    solvable: change.solvable
                )
            })
        }

        return childrenChanges.map { change in
            .update(
                id: typeId,
                updated: .property(property: change),
                breaking: change.breaking,
                solvable: change.solvable
            )
        }
    }

    private func _augmentIdentifiersOfSynthesizedTypes(of endpoint: Endpoint, with identifiers: EndpointSynthesizedTypes) {
        if let inputIdentifiers = identifiers.inputIdentifiers {
            precondition(endpoint.parameters.count == 1, "Unexpected endpoint count for \(endpoint)")
            let parameter = endpoint.parameters[0]
            parameter.typeInformation.augmentTypeWithIdentifiers(retrieveIdentifiers: { _ in inputIdentifiers })
        }

        if let outputIdentifiers = identifiers.outputIdentifiers {
            endpoint.response.augmentTypeWithIdentifiers(retrieveIdentifiers: { _ in outputIdentifiers })
        }
    }
}

private extension Endpoint {
    var swiftTypeName: String {
        handlerName.buildName(
            printTargetName: true,
            componentSeparator: ".",
            genericsStart: "<",
            genericsSeparator: ",",
            genericsDelimiter: ">"
        )
    }

    func updatedSwiftTypeName(considering migrationGuide: MigrationGuide) -> String {
        updatedIdentifier(for: TypeName.self, considering: migrationGuide)
            .buildName(
                printTargetName: true,
                componentSeparator: ".",
                genericsStart: "<",
                genericsSeparator: ",",
                genericsDelimiter: ">"
            )
    }
}
