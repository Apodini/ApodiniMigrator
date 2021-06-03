import Foundation

//public class PropertyName: PropertyValueWrapper<String> {}

public struct TypeProperty: Value {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case name, type, annotation
    }
    
    public let name: String
    public let type: TypeInformation
    public let annotation: FluentPropertyType?
    
    init(name: String, type: TypeInformation) {
        self.name = name
        self.type = type
        self.annotation = nil
    }
    
    init(name: String, type: TypeInformation, annotation: FluentPropertyType) {
        self.name = name
        self.type = type
        self.annotation = annotation
    }
}

extension TypeProperty {
    static func property(_ name: String, type: TypeInformation) -> TypeProperty {
        .init(name: name, type: type)
    }
    
    static func fluentProperty(_ name: String, type: TypeInformation, annotation: FluentPropertyType) -> TypeProperty {
        .init(name: name, type: type, annotation: annotation)
    }
}

public struct EnumCase: Value {
    public let name: String
    public let type: TypeInformation // currently only .scalar(.string)
    
    public init(_ name: String) {
        self.name = name
        self.type = .scalar(.string)
    }
}

extension EnumCase {
    static func `case`(_ name: String) -> EnumCase {
        .init(name)
    }
}
