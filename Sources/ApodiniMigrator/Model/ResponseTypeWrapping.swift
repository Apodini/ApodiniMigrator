//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A `ResponseTypeWrapping` can be used to introduce a wrapper type around the response type of an `Endpoint`.
/// Which endpoints are considered can be selected.
public protocol ResponseTypeWrapping {
    /// This predicate indicates if the response type of the given `Endpoint` should be wrapped.
    ///
    /// - Parameter endpoint: The `Endpoint` to check for.
    /// - Returns: Returns `true` if the given response type of the `Endpoint` should be wrapped.
    func shouldBeWrapped(endpoint: Endpoint) -> Bool

    /// When the ``shouldBeWrapped`` predicate returns `true`, this method is called to
    /// execute the actual wrapping step.
    ///
    /// The type wrapping MUST result in a newly introduced wrapper type which has exactly one property:
    /// the previous endpoint response!
    /// You may abort the wrapping process completely by returning `nil`.
    ///
    /// - Parameters:
    ///   - responseType: The response type of the given `Endpoint` which is to be wrapped.
    ///   - endpoint: The `Endpoint` which response type is mapped.
    /// - Returns: The new wrapper `TypeInformation`. Return `nil to abort the wrapping.
    func wrap(responseType: TypeInformation, of endpoint: Endpoint) -> TypeInformation?
}

private struct EndpointWrappedResponse {
    let wrapperTypeId: DeltaIdentifier
    let wrappedTypePropertyName: DeltaIdentifier
}

extension APIDocument {
    /// This method can be used to introduce a wrapped type for the response type of an `Endpoint`.
    /// The created wrapper type will be stored as a `reference` type in the `Endpoint`. Use the `TypeStore`
    /// of the `APIDocument` or the model additions in the `MigrationGuide` respectively to resolve the types.
    ///
    /// - Parameters:
    ///   - migrationGuide: The `MigrationGuide` which should be considered. Change types are migrated accordingly.
    ///   - typeWrapping: The ``ResponseTypeWrapping``.
    public mutating func applyEndpointResponseTypeWrapping(
        considering migrationGuide: inout MigrationGuide,
        using typeWrapping: ResponseTypeWrapping
    ) {
        // mapping: [Endpoint: EndpointWrappedResponse]
        var wrappedTypes: [DeltaIdentifier: EndpointWrappedResponse] = [:]

        unsafeEndpoints = unsafeEndpoints.map { endpoint -> Endpoint in
            wrapResponseType(of: endpoint, considering: &migrationGuide, using: typeWrapping, tracking: &wrappedTypes, storeInto: .apiDocument)
                ?? endpoint
        }

        handleResponseTypeWrappingOfAddedEndpoints(considering: &migrationGuide, using: typeWrapping)

        migrateRelevantEndpointChangesToModelChanges(of: wrappedTypes, considering: &migrationGuide)
    }

    private mutating func wrapResponseType(
        of endpoint: Endpoint,
        considering migrationGuide: inout MigrationGuide,
        using typeWrapping: ResponseTypeWrapping,
        tracking wrappedTypes: inout [DeltaIdentifier: EndpointWrappedResponse],
        storeInto storage: ModelStorageDestination
    ) -> Endpoint? {
        if !typeWrapping.shouldBeWrapped(endpoint: endpoint) {
            return nil
        }

        guard let wrapperType = typeWrapping.wrap(responseType: endpoint.response, of: endpoint) else {
            return nil // merge was aborted by returning nil
        }

        guard
            wrapperType.objectProperties.count == 1,
            let wrappedType = wrapperType.objectProperties.first else {
            preconditionFailure("Encountered unexpected state where wrapper type doesn't have exactly one property!")
        }

        wrappedTypes[endpoint.deltaIdentifier] = EndpointWrappedResponse(
            wrapperTypeId: wrapperType.deltaIdentifier,
            wrappedTypePropertyName: wrappedType.deltaIdentifier
        )

        var endpoint = endpoint

        switch storage {
        case .apiDocument:
            endpoint.response = add(type: wrapperType)
        case .migrationGuide:
            migrationGuide.modelChanges.append(.addition(
                id: wrapperType.deltaIdentifier,
                added: wrapperType
            ))

            endpoint.response = wrapperType.asReference()
        }


        return endpoint
    }

    private mutating func handleResponseTypeWrappingOfAddedEndpoints(
        considering migrationGuide: inout MigrationGuide,
        using typeWrapping: ResponseTypeWrapping
    ) {
        migrationGuide.endpointChanges = migrationGuide.endpointChanges.map { endpointChange in
            guard let additionChange = endpointChange.modeledAdditionChange else {
                return endpointChange
            }

            var sink: [DeltaIdentifier: EndpointWrappedResponse] = [:]

            if let modifiedEndpoint = wrapResponseType(
                of: additionChange.added,
                considering: &migrationGuide,
                using: typeWrapping,
                tracking: &sink,
                storeInto: .migrationGuide
            ) {
                return .addition(
                    id: additionChange.id,
                    added: modifiedEndpoint,
                    defaultValue: additionChange.defaultValue,
                    breaking: additionChange.breaking,
                    solvable: additionChange.solvable
                )
            }

            return endpointChange
        }
    }

    private mutating func migrateRelevantEndpointChangesToModelChanges(
        of endpointWrappedTypes: [DeltaIdentifier: EndpointWrappedResponse],
        considering migrationGuide: inout MigrationGuide
    ) {
        for endpointChange in migrationGuide.endpointChanges {
            guard let updateChange = endpointChange.modeledUpdateChange,
                  case let .response(from, to, backwardsMigration, migrationWarning) = updateChange.updated else {
                continue
            }

            guard let context = endpointWrappedTypes[updateChange.id] else {
                continue
            }

            // we are mapping all `.response` EndpointUpdateChanges of updated endpoints which response type got wrapped
            // into a `.type` PropertyUpdateChange for the wrapped type.

            let propertyChange: PropertyChange = .update(
                id: context.wrappedTypePropertyName,
                updated: .type(
                    from: from,
                    to: to,
                    // Its fine that we have not forward migration.
                    // The type will never be used as a parameter type.
                    // See `.type` migrations in `ParameterCombination`!
                    forwardMigration: -1,
                    backwardMigration: backwardsMigration,
                    conversionWarning: migrationWarning
                )
            )

            migrationGuide.modelChanges.append(.update(
                id: context.wrapperTypeId,
                updated: .property(property: propertyChange),
                breaking: propertyChange.breaking,
                solvable: propertyChange.solvable
            ))

            if let index = migrationGuide.endpointChanges.firstIndex(of: endpointChange) {
                migrationGuide.endpointChanges.remove(at: index)
            } else {
                fatalError("""
                           Encountered inconsistent data. Endpoint change which is part of the migration guide \
                           is not part of the migration guide! LMAO!
                           """)
            }
        }
    }
}
