//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public class TestTarget: Directory, TargetDirectory {
    public var type: TargetType {
        .test
    }

    public var dependencies: [TargetDependency] = []
    public var resources: [TargetResource] = []

    public override init(_ name: Name, @DefaultLibraryComponentBuilder content: () -> [LibraryComponent] = { [] }) {
        super.init(name, _content: content())
    }
}
