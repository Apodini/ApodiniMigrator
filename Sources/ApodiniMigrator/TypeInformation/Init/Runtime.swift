//
//  File.swift
//  
//
//  Created by Eldi Cano on 02.06.21.
//

import Foundation
@_implementationOnly import Runtime

func info(of type: Any.Type) throws -> TypeInfo {
    try Runtime.typeInfo(of: type)
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
}

struct RuntimeProperty {
    private let propertyInfo: PropertyInfo
    let typeInfo: TypeInfo
    var mangledName: MangledName {
        MangledName(typeInfo.mangledName)
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
