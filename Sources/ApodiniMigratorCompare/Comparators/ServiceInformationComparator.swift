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

        // TODO exporter configuration
        /*
         let lhsEncoderConfig = lhs.encoderConfiguration
        let rhsEncoderConfig = rhs.encoderConfiguration

        if lhsEncoderConfig != rhsEncoderConfig {
            changes.add(
                UpdateChange(
                    element: element(.encoderConfiguration),
                    from: .element(lhsEncoderConfig),
                    to: .element(rhsEncoderConfig),
                    breaking: true,
                    solvable: true
                )
            )
        }

        let lhsDecoderConfig = lhs.decoderConfiguration
        let rhsDecoderConfig = rhs.decoderConfiguration

        if lhsDecoderConfig != rhsDecoderConfig {
            changes.add(
                UpdateChange(
                    element: element(.decoderConfiguration),
                    from: .element(lhsDecoderConfig),
                    to: .element(rhsDecoderConfig),
                    breaking: true,
                    solvable: true
                )
            )
        }
         */
    }
}
