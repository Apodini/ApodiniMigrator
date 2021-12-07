//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct DocumentComparator: Comparator {
    let lhs: APIDocument
    let rhs: APIDocument
    let changes: ChangeContextNode
    let configuration: EncoderConfiguration
    
    func compare() {
        let metaDataComparator = ServiceInformationComparator(lhs: lhs.serviceInformation, rhs: rhs.serviceInformation, changes: changes, configuration: configuration)
        metaDataComparator.compare()
        
        let modelsComparator = ModelsComparator(
            lhs: lhs.allModels(),
            rhs: changes.set(rhsModels: rhs.allModels()),
            changes: changes,
            configuration: configuration
        )
        modelsComparator.compare()
        
        let endpointsComparator = EndpointsComparator(lhs: lhs.endpoints, rhs: rhs.endpoints, changes: changes, configuration: configuration)
        endpointsComparator.compare()
    }
}
