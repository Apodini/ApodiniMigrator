import Foundation

class PropertyName: PropertyValueWrapper<String> {}

struct TypeProperty: Value { // todo add required / cardinality based on type descriptor type
    let name: PropertyName
    let type: TypeDescriptor
}

struct EnumCase: Value {
    let name: PropertyName
    let type: TypeDescriptor // currently only .scalar(.string)
    
    init(_ name: String) {
        self.name = .init(name)
        self.type = .scalar(.string)
    }
}
