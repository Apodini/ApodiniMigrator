//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct ServiceInformationComparator: Comparator {
    let lhs: ServiceInformation
    let rhs: ServiceInformation

    func compare(_ context: ChangeComparisonContext, _ results: inout [ServiceInformationChange]) {
        if lhs.version.string != rhs.version.string {
            results.append(.update(
                id: lhs.deltaIdentifier,
                updated: .version(from: lhs.version, to: rhs.version),
                // while rest uses the version in the path, the path itself encodes that
                // breaking change via the EndpointIdentifierChange
                breaking: false
            ))
        }

        if lhs.http.description != rhs.http.description {
            results.append(.update(
                id: lhs.deltaIdentifier,
                updated: .http(from: lhs.http, to: rhs.http)
            ))
        }


        var types = Set(lhs.configuredExporters)
        types.formUnion(rhs.configuredExporters)
        for type in types {
            let lhsExporter = lhs.exporters[type]
            let rhsExporter = rhs.exporters[type]

            let change: ExporterConfigurationChange?
            switch (lhsExporter, rhsExporter) {
            case let (nil, .some(rhsExporter)):
                change = .addition(
                    id: rhsExporter.deltaIdentifier,
                    added: rhsExporter,
                    defaultValue: nil,
                    breaking: true,
                    solvable: false
                )
            case let (.some(lhsExporter), nil):
                change = .removal(
                    id: lhsExporter.deltaIdentifier,
                    removed: nil,
                    fallbackValue: nil,
                    breaking: true,
                    solvable: false
                )
            case let (.some(lhsExporter), .some(rhsExporter)):
                change = .update(
                    id: lhsExporter.deltaIdentifier,
                    updated: .init(from: lhsExporter, to: rhsExporter),
                    breaking: true,
                    solvable: true // we assume solve-ability
                )
            default:
                change = nil
            }

            if let change = change {
                results.append(.update(
                    id: lhs.deltaIdentifier,
                    updated: .exporter(exporter: change),
                    breaking: change.breaking,
                    solvable: change.solvable
                ))
            }
        }
    }
}
