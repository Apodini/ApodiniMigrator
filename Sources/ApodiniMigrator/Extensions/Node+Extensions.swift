import Foundation
@_implementationOnly import Runtime

// MARK: - ReflectionInfo Node extensions
extension Node where T == ReflectionInfo {
    // MARK: - Properties
    var isPrimitive: Bool {
        isSupportedScalarType(value.typeInfo.type)
    }

    var isEnum: Bool {
        value.typeInfo.kind == .enum
    }

    // MARK: - Functions
    func sanitized() -> Self {
        guard
            let sanitized = try?
                edited(handleOptional)?
                .edited(handleArray)?
                .edited(handleDictionary)?
                .edited(handlePrimitiveType)
        else { fatalError("Error occurred during transforming tree of nodes with type \(value.typeInfo.name).") }
        return sanitized
    }
    
    func handleCardinalities() -> Self {
        guard
            let newNode = try?
                edited(handleOptional)?
                .edited(handleArray)?
                .edited(handleDictionary)
        else { fatalError("Error occurred during transforming tree of nodes with type \(value.typeInfo.name).") }
        return newNode
    }
}

extension TypeInfo {
    var typeName: TypeName {
        .init(type)
    }
}
