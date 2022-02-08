//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// An internal protocol to restrict the initialization of `AnyCodableElement` with known types
protocol AnyCodableElementValue: Value {}

// MARK: - AnyCodableElementValue
extension AnyCodableElementValue {
    var asAnyCodableElement: AnyCodableElement {
        .init(self)
    }
}

// MARK: - AnyCodableElementValue conformance
extension APIDocument: AnyCodableElementValue {}
extension DeltaIdentifier: AnyCodableElementValue {}
extension Endpoint: AnyCodableElementValue {}
extension EndpointPath: AnyCodableElementValue {}
extension Parameter: AnyCodableElementValue {}
extension TypeInformation: AnyCodableElementValue {}
extension EncoderConfiguration: AnyCodableElementValue {}
extension DecoderConfiguration: AnyCodableElementValue {}
extension ApodiniMigratorCore.Operation: AnyCodableElementValue {}
extension Necessity: AnyCodableElementValue {}
extension TypeProperty: AnyCodableElementValue {}
extension ParameterType: AnyCodableElementValue {}
extension EnumCase: AnyCodableElementValue {}

// MARK: - AnyCodableElement
/// A type erasured Codable and Hashable for all model objects that can appear in different value sections of the Migration guide
public final class AnyCodableElement: Value, CustomStringConvertible {
    /// Value
    let value: Any
    
    /// JSON string representation of `value`, with `.sortedKeys` output formatting
    public var description: String {
        // swiftlint:disable:next force_cast
        (value as! Encodable).json()
    }
    
    // MARK: - Initializer
    /// Internal initializer that restricts the initialization only with values of known types that can be encoded and decoded by `AnyCodableElement`
    init<A: AnyCodableElementValue>(_ value: A) {
        self.value = value
    }
    
    /// Encodes `self` into the given encoder by encoding value into a singleValueContainer
    public func encode(to encoder: Encoder) throws { // swiftlint:disable:this cyclomatic_complexity
        var singleValueContainer = encoder.singleValueContainer()
        
        if let value = value as? APIDocument {
            try singleValueContainer.encode(value)
        } else if let value = value as? DeltaIdentifier {
            try singleValueContainer.encode(value)
        } else if let value = value as? LegacyEndpoint {
            try singleValueContainer.encode(value)
        } else if let value = value as? Endpoint {
            try singleValueContainer.encode(value)
        } else if let value = value as? EndpointPath {
            try singleValueContainer.encode(value)
        } else if let value = value as? Parameter {
            try singleValueContainer.encode(value)
        } else if let value = value as? TypeInformation {
            try singleValueContainer.encode(value)
        } else if let value = value as? EncoderConfiguration {
            try singleValueContainer.encode(value)
        } else if let value = value as? DecoderConfiguration {
            try singleValueContainer.encode(value)
        } else if let value = value as? ApodiniMigratorCore.Operation {
            try singleValueContainer.encode(value)
        } else if let value = value as? ParameterType {
            try singleValueContainer.encode(value)
        } else if let value = value as? Necessity {
            try singleValueContainer.encode(value)
        } else if let value = value as? TypeProperty {
            try singleValueContainer.encode(value)
        } else if let value = value as? EnumCase {
            try singleValueContainer.encode(value)
        } else {
            throw EncodingError.invalidValue(value, .init(codingPath: [], debugDescription: "\(Self.self) did not encode any value"))
        }
    }
    
    /// Creates a new instance by decoding from the given decoder
    public init(from decoder: Decoder) throws { // swiftlint:disable:this cyclomatic_complexity
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(APIDocument.self) {
            self.value = value
        } else if let value = try? container.decode(Necessity.self) {
            self.value = value
        } else if let value = try? container.decode(ParameterType.self) {
            self.value = value
        } else if let value = try? container.decode(ApodiniMigratorCore.Operation.self) {
            self.value = value
        } else if let value = try? container.decode(LegacyEndpoint.self) {
            self.value = Endpoint(from: value)
        } else if let value = try? container.decode(Endpoint.self) {
            self.value = value
        } else if let value = try? container.decode(EndpointPath.self) {
            self.value = value
        } else if let value = try? container.decode(DeltaIdentifier.self) {
            self.value = value
        } else if let value = try? container.decode(Parameter.self) {
            self.value = value
        } else if let value = try? container.decode(TypeInformation.self) {
            self.value = value
        } else if let value = try? container.decode(EncoderConfiguration.self) {
            self.value = value
        } else if let value = try? container.decode(DecoderConfiguration.self) {
            self.value = value
        } else if let value = try? container.decode(TypeProperty.self) {
            self.value = value
        } else if let value = try? container.decode(EnumCase.self) {
            self.value = value
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Failed to decode \(Self.self)")
        }
    }

    /// Returns the typed value. The method is to be used by migrator objects to cast the element of change after ensuring the type
    /// via the target value of the element. E.g. for an element `.endpoint(id, target: .operation)`, the value can be casted as `.typed(Operation.self)`
    public func tryTyped<C: Codable>(_ type: C.Type = C.self) -> C? {
        value as? C
    }
}

// MARK: - Hashable
public extension AnyCodableElement {
    /// Feeds the `description` into the hasher
    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}

// MARK: - Equatable
public extension AnyCodableElement {
    /// Checks equality based on the `description`
    static func == (lhs: AnyCodableElement, rhs: AnyCodableElement) -> Bool {
        lhs.description == rhs.description
    }
}
