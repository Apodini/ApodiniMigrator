//
//  Array+Extensions.swift
//  ApodiniMigratorShared
//
//  Created by Eldi Cano on 27.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

public extension Array where Element: Hashable {
    /// Unique elements contained in self
    func unique() -> Self {
        Set(self).asArray
    }
}

public extension Sequence {
    /// Returns a sorted version of self by a comparable element keypath
    func sorted<C: Comparable>(by keyPath: KeyPath<Element, C>, increasingOrder: Bool = true) -> [Element] {
        let sorted = self.sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
        return increasingOrder ? sorted : sorted.reversed()
    }
    
    /// Returns the first matched element, where the value of the property is equal to other
    func firstMatch<E: Equatable>(on keyPath: KeyPath<Element, E>, with other: E) -> Element? {
        first(where: { $0[keyPath: keyPath] == other })
    }
}

public extension Array where Element: Equatable {
    /// Returns whether self is equal to other not considering the order of elements
    func equalsIgnoringOrder(to other: Self) -> Bool {
        guard count == other.count else {
            return false
        }

        for element in self where !other.contains(element) {
            return false
        }

        return true
    }
    
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
