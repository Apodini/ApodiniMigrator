import Foundation

public struct TypeProperty: Value {
    public let name: String
    public let type: TypeInformation
    public let annotation: FluentPropertyType?
    
    init(name: String, type: TypeInformation, annotation: FluentPropertyType? = nil) {
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
