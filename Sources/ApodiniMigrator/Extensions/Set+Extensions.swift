

import Foundation

extension Set {
    static var empty: Self { [] }
    
    var asArray: [Element] {
        Array(self)
    }

    static func += (lhs: inout Self, rhs: Element) {
        lhs.insert(rhs)
    }

    static func += <S: Sequence> (lhs: inout Self, rhs: S) where S.Element == Element {
        lhs.formUnion(rhs)
    }
}
