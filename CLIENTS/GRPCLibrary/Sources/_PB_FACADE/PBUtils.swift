//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftProtobuf

public typealias SwiftProtobufProtocols = SwiftProtobuf.Message & SwiftProtobuf._MessageImplementationBase & SwiftProtobuf._ProtoNameProviding

// TODO conformance to CustomReflectable

public protocol SwiftProtobufWrapper: SwiftProtobufProtocols {
    associatedtype Wrapped: SwiftProtobufProtocols

    var __wrapped: Wrapped { get set }// TODO access protection!!
    // TODO fileprivate var wrapped: _PB_GENERATED.GreeterMessage

    subscript<T>(dynamicMember member: KeyPath<Wrapped, T>) -> T { get }

    subscript<T>(dynamicMember member: WritableKeyPath<Wrapped, T>) -> T { get set }
}

// MARK: @dynamicMemberLookup
public extension SwiftProtobufWrapper {
    subscript<T>(dynamicMember member: KeyPath<Wrapped, T>) -> T {
        get {
            __wrapped[keyPath: member]
        }
    }

    subscript<T>(dynamicMember member: WritableKeyPath<Wrapped, T>) -> T {
        get {
            __wrapped[keyPath: member]
        }
        set {
            __wrapped[keyPath: member] = newValue
        }
    }
}

// MARK: SwiftProtobufProtocols
public extension SwiftProtobufWrapper {
    public static var protoMessageName: String {
        Wrapped.protoMessageName
    }

    public static var _protobuf_nameMap: _NameMap {
        Wrapped._protobuf_nameMap
    }

    public var unknownFields: UnknownStorage {
        get {
            __wrapped.unknownFields
        }
        set(newValue) {
            __wrapped.unknownFields = newValue
        }
    }

    public mutating func decodeMessage<D: Decoder>(decoder: inout D) throws {
        try __wrapped.decodeMessage(decoder: &decoder)
    }

    public func traverse<V: Visitor>(visitor: inout V) throws {
        try __wrapped.traverse(visitor: &visitor)
    }
}
