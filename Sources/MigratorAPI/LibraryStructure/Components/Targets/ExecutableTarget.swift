//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

public class Executable: Target {
    public override var type: TargetType {
        .executable
    }

    public override init(_ name: NameComponent..., @DefaultLibraryComponentBuilder content: () -> [LibraryComponent] = { [] }) {
        super.init(name, _content: content())
    }
}
