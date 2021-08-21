//
//  DefaultInitializable.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// `Default` is an empty struct that can either be initalized with `.init()` or
/// `.default` static variable. It is used as a parameter in `DefaultInitializable` initializer
/// to disambiguate it from the overload of default `.init()` initializers of most primitive values. The variable
/// `default` is however not used within the initializer at all. The present of `Default` additionally
/// serves the purpose to avoid `Self` in `DefaultInitializable`, and also for conforming Arrays,
/// Dictionaries and Optionals to `DefaultInitializable` where the respective element, keys, values or wrapped
/// conform to `DefaultInitializable` by ensuring to initializing them with one element.
///  Check for conformance to `DefaultInitializable` is done on instance creation
/// operations of empty properties of arrays, dictionaries and optionals, before passing to `createInstance` of Runtime
public struct Default {
    /// Default static variable of `Self`
    public static let `default`: Default = .init()
    
    /// Empty initializer
    public init() {}
    
    /// A convenience static func to retrieve the typed default value of a `DefaultInitializable` type.
    /// e.g. `let date = Default.value(of: Date.self)` would return the date of today noon.
    public static func value<D: DefaultInitializable>(of type: D.Type) -> D {
        D.default
    }
}

/// A protocol for types that implement by default their type information representation
public protocol TypeInformationPrimitiveConstructor {
    /// Returns the default type information
    static func construct() -> TypeInformation
}

/// A protocol that forces the presence of an `init(_ default: Default)` initializer,
/// where `Default` is an empty struct that can either be initalized with `.init()` or
/// `.default` static variable.
public protocol DefaultInitializable: Encodable, TypeInformationPrimitiveConstructor {
    init(_ default: Default)
}

// MARK: - Default
public extension DefaultInitializable {
    /// Default value as returned by `init(_:)`
    static var `default`: Self { .init(.default) }
    /// Json string of the default value
    static var jsonString: String { `default`.json }
}

// MARK: - DefaultInitializable conformance
extension Null: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.null)
    }
}

extension Int: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.int)
    }
}

extension Int8: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.int8)
    }
}

extension Int16: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.int16)
    }
}

extension Int32: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.int32)
    }
}

extension Int64: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.int64)
    }
}

extension UInt: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.uint)
    }
}

extension UInt8: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.uint8)
    }
}

extension UInt16: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.uint16)
    }
}

extension UInt32: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.uint32)
    }
}

extension UInt64: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.uint64)
    }
}

extension Bool: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.bool)
    }
}

extension Double: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.double)
    }
}

extension Float: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.float)
    }
}

extension Data: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.data)
    }
}

extension String: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self.init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.string)
    }
}

extension URL: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        // swiftlint:disable:next force_unwrapping
        self = URL(string: "https://github.com/Apodini/ApodiniMigrator.git")!
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.url)
    }
}

extension UUID: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self = .init()
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.uuid)
    }
}

extension Date: DefaultInitializable {
    var noon: Date {
        Calendar(identifier: .gregorian).date(bySettingHour: 12, minute: 0, second: 0, of: self) ?? self
    }
    
    /// Default initializer
    public init(_ default: Default) {
        self = Date().noon
    }
    
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .scalar(.date)
    }
}

extension Array: DefaultInitializable where Element: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self = [.init(.default)]
    }
}

extension Array: TypeInformationPrimitiveConstructor where Element: DefaultInitializable {
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .repeated(element: Element.construct())
    }
}

extension Set: DefaultInitializable where Element: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self = [.init(.default)]
    }
}

extension Set: TypeInformationPrimitiveConstructor where Element: DefaultInitializable {
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .repeated(element: Element.construct())
    }
}

extension Dictionary: DefaultInitializable where Key: DefaultInitializable, Value: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self = [.init(.default): .init(.default)]
    }
}

extension Dictionary: TypeInformationPrimitiveConstructor where Key: DefaultInitializable, Value: DefaultInitializable {
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        guard let primitiveType = PrimitiveType(Key.self) else {
            fatalError("Encountered a non primtive `DefaultInializable` type: \(Key.self)")
        }
        return .dictionary(key: primitiveType, value: Value.construct())
    }
}

extension Optional: DefaultInitializable where Wrapped: DefaultInitializable {
    /// Default initializer
    public init(_ default: Default) {
        self = .some(.init(.default))
    }
}

extension Optional: TypeInformationPrimitiveConstructor where Wrapped: DefaultInitializable {
    /// Returns the default type information
    public static func construct() -> TypeInformation {
        .optional(wrappedValue: Wrapped.construct())
    }
}
