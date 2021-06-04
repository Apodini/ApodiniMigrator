import Foundation
@_implementationOnly import Runtime

func info(of type: Any.Type) throws -> TypeInfo {
    try Runtime.typeInfo(of: type)
}

func createInstance(of type: Any.Type) throws -> Any {
    try Runtime.createInstance(of: type)
}

func cardinality(of type: Any.Type) throws -> Cardinality {
    try info(of: type).cardinality
}

func knownRuntimeError(_ error: Error) -> Bool {
    [Runtime.Kind.opaque, .function, .existential, .metatype]
        .map { "Runtime.Kind.\($0)" }
        .contains(where: { String(describing: error).contains($0) })
}


// MARK: - TypeInfo
extension TypeInfo {
    /// TypeName of the type of the `Runtime.TypeInfo`
    var typeName: TypeName {
        .init(type)
    }
    
    func properties() throws -> [RuntimeProperty] {
        try properties.map { try .init($0) }
    }
    
    var cardinality: Cardinality {
        let mangledName = MangledName(self.mangledName)
        if mangledName == .repeated, let elementType = genericTypes.first {
            return .repeated(elementType)
        } else if mangledName == .optional, let wrappedValueType = genericTypes.first {
            return .optional(wrappedValueType)
        } else if mangledName == .dictionary, let keyType = genericTypes.first, let valueType = genericTypes.last {
            return .dictionary(key: keyType, value: valueType)
        } else { return .exactlyOne(type) }
    }
}

struct RuntimeProperty {
    static let wrappedValuePropertyName = "wrappedValue"
    
    let propertyInfo: PropertyInfo
    let typeInfo: TypeInfo
    var mangledName: MangledName {
        MangledName(typeInfo.mangledName)
    }
    
    var caridinality: Cardinality {
        typeInfo.cardinality
    }
    
    var name: String {
        isFluentProperty
            ? String(propertyInfo.name.dropFirst())
            : propertyInfo.name
    }
    
    var type: Any.Type {
        propertyInfo.type
    }
    
    var ownerType: Any.Type {
        propertyInfo.ownerType
    }
    
    var wrappedValueProperty: RuntimeProperty? {
        if propertyInfo.name.starts(with: "_") {
           return try? typeInfo.properties().firstMatch(on: \.name, with: Self.wrappedValuePropertyName)
        }
        return nil
    }
    
    var propertyWrapperWrappedValueType: Any.Type? {
        wrappedValueProperty?.type
    }
    
    var fluentPropertyType: FluentPropertyType? {
        if case let .fluentPropertyType(fluentPropertyType) = mangledName {
            return fluentPropertyType
        }
        return nil
    }
    
    var isFluentProperty: Bool {
        fluentPropertyType != nil
    }
    
    var isIDProperty: Bool {
        fluentPropertyType == .iDProperty
    }
    
    var genericTypes: [Any.Type] {
        typeInfo.genericTypes
    }
    
    init(_ propertyInfo: PropertyInfo) throws {
        self.propertyInfo = propertyInfo
        self.typeInfo = try info(of: propertyInfo.type)
    }
}
