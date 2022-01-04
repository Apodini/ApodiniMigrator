//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public extension Array {
    /// This method can be used to flatten an array of arrays.
    /// - Returns: Returns the flattened array, where they are all append to one big array.
    func flatten<InnerElement>() -> [InnerElement] where Element == [InnerElement] {
        self.reduce(into: []) { result, element in
            result.append(contentsOf: element)
        }
    }
}

public extension Array where Element: Hashable {
    /// Unique elements contained in self
    func unique() -> Self {
        Set(self).asArray
    }
}

public extension Sequence {
    /// Returns a sorted version of self by a comparable element keypath
    func sorted<C: Comparable>(by keyPath: KeyPath<Element, C>) -> [Element] {
        self.sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}

public extension Array where Element: Equatable {
    /// Returns a new array in which all occurrences of a `target` element are replaced with `replacement` element.
    func replacingOccurrences(ofElement target: Element, with replacement: Element) -> Self {
        reduce(into: Self()) { result, current in
            result.append(current == target ? replacement : current)
        }
    }
    /// Mutating version of `replacingOccurrences(ofElement:with:)`
    mutating func replacingOccurrences(of target: Element, with replacement: Element) {
        self = replacingOccurrences(ofElement: target, with: replacement)
    }
}
