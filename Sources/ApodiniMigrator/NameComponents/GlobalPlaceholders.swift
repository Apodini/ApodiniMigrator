//
// Created by Andreas Bauer on 28.12.21.
//

import Foundation

public extension Placeholder {
    static var packageName: Placeholder {
        Placeholder("PACKAGE_NAME")
    }
}

public extension Name {
    static var packageName: Name {
        "\(.packageName)"
    }
}
