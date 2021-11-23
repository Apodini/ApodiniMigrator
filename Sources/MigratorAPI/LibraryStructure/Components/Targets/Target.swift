//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation
import PathKit

public class Target: Directory, TargetDirectory {
    public var type: TargetType {
        .regular
    }

    public var dependencies: [TargetDependency] = []

    public override init(_ name: NameComponent..., @DefaultLibraryComponentBuilder content: () -> [LibraryComponent] = { [] }) {
        super.init(name, _content: content())
    }

    override init(_ name: [NameComponent], _content: [LibraryComponent]) {
        super.init(name, _content: _content)
    }
}
