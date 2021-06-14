import Foundation

public enum Optionality: String, Value {
    case optional
    case required
}

public struct TypeProperty: Value {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case name, type, annotation
    }
    public let name: String
    public let type: TypeInformation
    public let annotation: String?
    
    public var optionality: Optionality {
        type.isOptional ? .optional : .required
    }
    
    init(name: String, type: TypeInformation, annotation: String? = nil) {
        self.name = name
        self.type = type
        self.annotation = annotation
    }
}

extension TypeProperty: DeltaIdentifiable {
    public var deltaIdentifier: DeltaIdentifier { .init(name) }
}

extension TypeProperty {
    static func property(_ name: String, type: TypeInformation) -> TypeProperty {
        .init(name: name, type: type)
    }
    
    static func fluentProperty(_ name: String, type: TypeInformation, annotation: String) -> TypeProperty {
        .init(name: name, type: type, annotation: annotation)
    }
}
