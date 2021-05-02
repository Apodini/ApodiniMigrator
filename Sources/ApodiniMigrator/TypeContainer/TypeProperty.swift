import Foundation


protocol Property {
    var name: PropertyName { get }
    var type: TypeContainer { get }
}

struct TypeProperty: Property, Value {
    let name: PropertyName
    let type: TypeContainer
}

struct EnumCase: Property, Value {
    let name: PropertyName
    let type: TypeContainer // currently only .primitive(.string)
    
    init(_ name: String) {
        self.name = .init(name)
        self.type = .primitive(.string)
    }
}
