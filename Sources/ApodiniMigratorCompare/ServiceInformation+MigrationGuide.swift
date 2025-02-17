//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public extension ServiceInformation {
    /// Force retrieves a `ExporterConfiguration`.
    /// This method considers updates of the supplied ``MigrationGuide`` (e.g. if a ExporterConfiguration was removed in the update `APIDocument`).
    func exporter<Exporter: ExporterConfiguration>(
        for type: Exporter.Type = Exporter.self,
        migrationGuide: MigrationGuide
    ) -> Exporter {
        guard let exporter = exporterIfPresent(for: type, migrationGuide: migrationGuide) else {
            fatalError("Failed to retrieve exporter from ServiceInformation: \(type)")
        }

        return exporter
    }

    /// Retrieve the `ExporterConfiguration` if its present.
    /// This method considers updates of the supplied ``MigrationGuide`` (e.g. if a ExporterConfiguration was removed in the update `APIDocument`).
    func exporterIfPresent<Exporter: ExporterConfiguration>(
        for type: Exporter.Type = Exporter.self,
        migrationGuide: MigrationGuide
    ) -> Exporter? {
        guard let exporter = exporters[Exporter.type] else {
            return nil
        }

        for changes in migrationGuide.serviceChanges {
            guard let updateChange = changes.modeledUpdateChange,
                  case let .exporter(exporterChange) = updateChange.updated else {
                continue
            }

            if let exporterUpdate = exporterChange.modeledUpdateChange { // if it was updated, return the update configuration!
                if let exporter = exporterUpdate.updated.to.tryTyped(of: Exporter.self) {
                    return exporter
                }
            } else if let exporterRemoval = exporterChange.modeledRemovalChange,
                      exporterRemoval.id == Exporter.deltaIdentifier { // if it was removed, return no exporter
                return nil
            }
        }

        return exporter.typed()
    }
}
