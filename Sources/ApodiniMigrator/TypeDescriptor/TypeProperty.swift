

import Foundation

class PropertyName: PropertyValueWrapper<String> {}

struct TypeProperty: Value {
    let name: PropertyName
    let type: TypeDescriptor
    
    var isRequired: Bool {
        !type.isOptional
    }
}

struct EnumCase: Value {
    let name: PropertyName
    let type: TypeDescriptor // currently only .scalar(.string)
    
    init(_ name: String) {
        self.name = .init(name)
        self.type = .scalar(.string)
    }
}
