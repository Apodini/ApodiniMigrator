//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

public class Tests: Directory, TargetContainingDirectory {
    public var targets: [TargetDirectory] {
        content as! [TargetDirectory]
    }

    public init(@TargetLibraryComponentBuilder<TestTarget> content: () -> [TargetDirectory] = { [] }) {
        super.init("Tests", content: content)
    }
}
