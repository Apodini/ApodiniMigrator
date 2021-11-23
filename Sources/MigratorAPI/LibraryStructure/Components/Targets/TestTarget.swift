//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

public class TestTarget: Directory, TargetDirectory {
    public var type: TargetType {
        .test
    }

    public var dependencies: [TargetDependency] = []

    public override init(_ name: NameComponent..., @DefaultLibraryComponentBuilder content: () -> [LibraryComponent] = { [] }) {
        super.init(name, _content: content())
    }
}
