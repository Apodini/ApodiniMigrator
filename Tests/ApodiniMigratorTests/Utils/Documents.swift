//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

enum Documents: String, TestResource {
    // documents generate with 1.0.0/legacy document version!
    case v1 = "api_qonectiq1.0.0_1"
    case v2 = "api_qonectiq2.0.0_1"
    case migrationGuide = "migration_guide_1"
    case serviceInformation = "service_information"
    case endpoints = "endpoints"

    // documents generate with document version of 2.1.0
    case v1_2 = "api_qonectiq1.0.0_2" // swiftlint:disable:this identifier_name
    case v2_2 = "api_qonectiq2.0.0_2" // swiftlint:disable:this identifier_name
    case migrationGuide_2 = "migration_guide_2" // swiftlint:disable:this identifier_name

    case protobufCodeGeneratorRequest = "protobuf-code-generator-request"

    var fileName: String {
        rawValue + ".json"
    }
}
