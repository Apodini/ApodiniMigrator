//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniTypeInformation

extension TypeName: Sequence {
    public typealias Iterator = Array<TypeNameComponent>.Iterator

    public func makeIterator() -> Iterator {
        var components: [TypeNameComponent] = nestedTypes
        components.append(TypeNameComponent(name: mangledName, generics: generics)) // TODO port to TypeInformation framework

        return components.makeIterator()
    }
}
