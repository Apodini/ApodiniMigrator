//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
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
