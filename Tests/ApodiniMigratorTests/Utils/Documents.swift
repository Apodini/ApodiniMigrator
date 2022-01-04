//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

enum Documents: String, TestResource {
    case v1 = "api_qonectiq1.0.0"
    case v2 = "api_qonectiq2.0.0"
    case migrationGuide = "migration_guide"

    var fileName: String {
        rawValue + ".json"
    }
}
