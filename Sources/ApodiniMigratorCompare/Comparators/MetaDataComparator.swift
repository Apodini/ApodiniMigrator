//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct MetaDataComparator: Comparator {
    let lhs: ServiceInformation
    let rhs: ServiceInformation
    let changes: ChangeContextNode
    var configuration: EncoderConfiguration
    
    func compare() {
        func element(_ target: NetworkingTarget) -> ChangeElement {
            .networking(target: target)
        }
        
        if lhs.versionedServerPath != rhs.versionedServerPath {
            changes.add(
                UpdateChange(
                    element: element(.serverPath),
                    from: .stringValue(lhs.versionedServerPath),
                    to: .stringValue(rhs.versionedServerPath),
                    breaking: true,
                    solvable: true
                )
            )
        }
        
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
    }
}
