import Foundation

//public class PropertyName: PropertyValueWrapper<String> {}

public struct TypeProperty: Value {
    public let name: String
    public let type: TypeInformation
}

public struct EnumCase: Value {
    public let name: String
    public let type: TypeInformation // currently only .scalar(.string)
    
    public init(_ name: String) {
        self.name = name
        self.type = .scalar(.string)
    }
}
