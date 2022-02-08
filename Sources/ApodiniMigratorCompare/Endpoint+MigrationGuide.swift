//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

extension Endpoint {
    /// Retrieve an `EndpointIdentifier` of the `Endpoint`.
    /// This method considers changes of the `EndpointIdentifier` in the `MigrationGuide`.
    public func updatedIdentifierIfPresent<Identifier: EndpointIdentifier>(
        for type: Identifier.Type = Identifier.self,
        considering migrationGuide: MigrationGuide
    ) -> Identifier? {
        let identifier = identifiers.identifierIfPresent(for: type)
        return checkForUpdated(identifier: type, in: migrationGuide) ?? identifier
    }

    /// Retrieve an `EndpointIdentifier` of the `Endpoint`.
    /// This method considers changes of the `EndpointIdentifier` in the `MigrationGuide`.
    public func updatedIdentifier<Identifier: EndpointIdentifier>(
        for type: Identifier.Type = Identifier.self,
        considering migrationGuide: MigrationGuide
    ) -> Identifier {
        let identifier = identifiers.identifier(for: type)
        return checkForUpdated(identifier: type, in: migrationGuide) ?? identifier
    }

    private func checkForUpdated<Identifier: EndpointIdentifier>(identifier: Identifier.Type, in migrationGuide: MigrationGuide) -> Identifier? {
        for change in migrationGuide.endpointChanges where change.id == self.deltaIdentifier {
            guard let updateChange = change.modeledUpdateChange,
                  case let .identifier(identifier) = updateChange.updated else {
                continue
            }

            // we currently only consider update changes
            guard let updatedIdentifier = identifier.modeledUpdateChange,
                  updatedIdentifier.id.rawValue == Identifier.identifierType else {
                continue
            }

            return updatedIdentifier.updated.to.typed(of: Identifier.self)
        }

        return nil
    }
}
