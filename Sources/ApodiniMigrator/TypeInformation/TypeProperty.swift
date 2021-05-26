import Foundation

public class PropertyName: PropertyValueWrapper<String> {}

public struct TypeProperty: Value {
    public let name: PropertyName
    public let type: TypeInformation
}

public struct EnumCase: Value {
    public let name: PropertyName
    public let type: TypeInformation // currently only .scalar(.string)
    
    public init(_ name: String) {
        self.name = .init(name)
        self.type = .scalar(.string)
    }
}
