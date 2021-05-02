//
//  Created by Nityananda on 11.12.20.
//

@_implementationOnly import Runtime

/// `PropertyInfo` models the property/field/member layout in a composite type.
struct PropertyInfo: Equatable, Hashable {
    let name: String
    let offset: Int
    
    init(name: String, offset: Int) {
        self.name = name
        self.offset = offset
    }
}

/// `ReflectionInfo` is the composite of a type's type info and property info, if it is embedded in
/// a composite type.
struct ReflectionInfo {
    /// `Cardinality`, i.e., the number of elements in a grouping, as a property of that grouping,
    /// models how many times a value appears for a property.
    enum Cardinality: Equatable, Hashable {
        case zeroToOne
        case exactlyOne
        case zeroToMany(CollectionContext)
    }
    
    /// `CollectionContext` further models the grouping of values for a property.
    enum CollectionContext: Equatable, Hashable {
        case array
        indirect case dictionary(key: ReflectionInfo, value: ReflectionInfo)
    }
    
    /// The type info reflecting a type.
    let typeInfo: TypeInfo
    /// The property info, if the type was embedded in a composite type.
    let propertyInfo: PropertyInfo?
    /// The cardinality of a property.
    ///
    /// `.exactlyOne` by default.
    var cardinality: Cardinality
    
    /// Initialize an `ReflectionInfo` instance.
    init(
        typeInfo: TypeInfo,
        propertyInfo: PropertyInfo?,
        cardinality: Cardinality = .exactlyOne
    ) {
        self.typeInfo = typeInfo
        self.propertyInfo = propertyInfo
        self.cardinality = cardinality
    }
}

extension ReflectionInfo {
    /// Recursively initialize a `ReflectionInfo` node from a root type.
    /// - Parameter type: The type that should be reflected.
    /// - Throws: A `RuntimeError`, if `Runtime` encounters an error during reflection.
    /// - Returns: A node of values reflecting every type composing the root type.
    static func node(_ type: Any.Type) throws -> Node<ReflectionInfo> {
        let typeInfo = try Runtime.typeInfo(of: type)
        let root = ReflectionInfo(
            typeInfo: typeInfo,
            propertyInfo: nil
        )

        return Node(root: root) { info in
            info.typeInfo.properties
                .enumerated()
                .compactMap { offset, propertyInfo in
                    do {
                        let typeInfo = try Runtime.typeInfo(of: propertyInfo.type)
                        return ReflectionInfo(
                            typeInfo: typeInfo,
                            propertyInfo: .init(
                                name: propertyInfo.name,
                                offset: offset + 1
                            )
                        )
                    } catch {
                        let errorDescription = String(describing: error)
                        let keywords = [
                            "\(Runtime.Kind.opaque)",
                            "\(Runtime.Kind.function)"
                        ]

                        let errorIsKnown = keywords.contains(where: { keyword in
                            errorDescription.contains(keyword)
                        })
                        
                        if errorIsKnown {
                            return nil
                        }
                        
                        preconditionFailure(errorDescription)
                    }
                }
        }
    }
}

// MARK: - ReflectionInfo: Hashable

extension ReflectionInfo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(typeInfo.name)
        hasher.combine(propertyInfo)
        hasher.combine(cardinality)
    }
}

// MARK: - ReflectionInfo: Equatable

extension ReflectionInfo: Equatable {
    static func == (lhs: ReflectionInfo, rhs: ReflectionInfo) -> Bool {
        lhs.typeInfo.type == rhs.typeInfo.type
            && lhs.propertyInfo == rhs.propertyInfo
            && lhs.cardinality == rhs.cardinality
    }
}
