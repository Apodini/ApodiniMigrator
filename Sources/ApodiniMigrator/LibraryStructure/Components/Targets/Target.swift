//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit

public class Target: Directory, TargetDirectory {
    public var type: TargetType {
        .regular
    }

    public var dependencies: [TargetDependency] = []
    public var resources: [TargetResource] = []

    public override init(_ name: Name, @DefaultLibraryComponentBuilder content: () -> [LibraryComponent] = { [] }) {
        super.init(name, _content: content())
    }

    override init(_ name: Name, _content: [LibraryComponent]) {
        super.init(name, _content: _content)
    }
}
