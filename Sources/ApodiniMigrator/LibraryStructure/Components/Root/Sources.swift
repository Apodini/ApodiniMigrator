//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

public class Sources: Directory, TargetContainingDirectory {
    public var targets: [TargetDirectory] {
        content as! [TargetDirectory]
    }

    public init(@TargetLibraryComponentBuilder<Target> content: () -> [TargetDirectory] = { [] }) {
        super.init("Sources", content: content)
    }
}
