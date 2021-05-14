//
//  File.swift
//  
//
//  Created by Eldi Cano on 29.03.21.
//

import Foundation

/// A protocol used to restrict values passed to `PropertyValueWrapper`
public protocol PropertyProtocol: Value {}

extension String: PropertyProtocol {}
extension Bool: PropertyProtocol {}
extension Int: PropertyProtocol {}

/// An abstract class that already conforms to ComparableProperty that wrapps values of a certain `PropertyProtocol` type.
///
/// The logic of registering changes to a `ChangeContextNode`, requires unique types for properties of a `ComparableObject`
///
/// Not accepted example by the `ChangeContextNode`:
/// ```swift
/// struct User: ComparableObject {
///     let name: String
///     let surname: String
/// }
/// ```
/// Registering the comparison result of two user instances, the change of `name` property, would be overwritten by the change
/// of `surname` property of the same type `String`
///
/// By means of `PropertyValueWrapper<P: PropertyProtocol>` we guarantee unique types as follows:
/// ```swift
/// class UserName: PropertyValueWrapper<String> {}
/// class UserSurname: PropertyValueWrapper<String> {}
///
/// struct User: ComparableObject {
///     let name: UserName
///     let surname: UserSurname
/// }
/// ```
public class PropertyValueWrapper<P: PropertyProtocol>: ComparableProperty {
    public let value: P

    public init(_ value: P) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
    public required init(from decoder: Decoder) throws {
        value = try decoder.singleValueContainer().decode(P.self)
    }
}

public extension PropertyValueWrapper {
    public static func == (lhs: PropertyValueWrapper<P>, rhs: PropertyValueWrapper<P>) -> Bool {
        lhs.value == rhs.value
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
