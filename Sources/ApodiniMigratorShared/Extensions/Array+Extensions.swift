//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.03.21.
//

import Foundation

public extension Array where Element: Hashable {
    func unique() -> Self {
        Set(self).asArray
    }
}

public extension Sequence {
    func sorted<C: Comparable>(by keyPath: KeyPath<Element, C>, increasingOrder: Bool = true) -> [Element] {
        let sorted = self.sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
        return increasingOrder ? sorted : sorted.reversed()
    }
}

public extension Array where Element: Equatable {
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
    
    mutating func replacingOccurrences(of target: Element, with replacement: Element) {
        self = replacingOccurrences(ofElement: target, with: replacement)
    }
}
