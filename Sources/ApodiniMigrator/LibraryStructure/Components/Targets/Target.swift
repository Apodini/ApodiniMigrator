//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit

/// A regular swift ``Sources`` target.
public class Target: Directory, TargetDirectory {
    public var type: TargetType {
        .regular
    }

    public var dependencies: [TargetDependency] = []
    public var resources: [TargetResource] = []

    override public init(_ name: Name, @DefaultLibraryComponentBuilder content: () -> [LibraryComponent] = { [] }) {
        super.init(name, _content: content())
    }

    override init(_ name: Name, _content: [LibraryComponent]) { // swiftlint:disable:this identifier_name
        super.init(name, _content: _content)
    }
}
