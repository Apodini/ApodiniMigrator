import Foundation

extension Set where Element == Schema {
    func save(in schemaBuilder: inout SchemaBuilder) {
        schemaBuilder.addSchemas(self)
    }
}

extension Set {
    static var empty: Self { [] }
    
    var asArray: [Element] {
        Array(self)
    }

    public static func += (lhs: inout Self, rhs: Element) {
        lhs.insert(rhs)
    }

    public static func += <S: Sequence> (lhs: inout Self, rhs: S) where S.Element == Element {
        lhs.formUnion(rhs)
    }
}
