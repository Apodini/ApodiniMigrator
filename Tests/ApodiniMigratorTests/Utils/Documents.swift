//
// Created by Andreas Bauer on 29.11.21.
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
