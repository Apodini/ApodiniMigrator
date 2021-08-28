//
//  TestFileTemplate.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import ApodiniMigratorClientSupport
import ApodiniMigratorShared

public struct TestFileTemplate: Renderable {
    let models: [TypeInformation]
    let fileName: String
    let packageName: String
    let objectJSONs: [String: JSONValue]
    let encoderConfiguration: EncoderConfiguration
    
    public init(
        _ models: [TypeInformation],
        objectJSONs: [String: JSONValue] = [:],
        encoderConfiguration: EncoderConfiguration = .default,
        fileName: String,
        packageName: String
    ) {
        self.models = models.sorted(by: \.typeString)
        self.fileName = fileName
        self.packageName = packageName
        self.objectJSONs = objectJSONs
        self.encoderConfiguration = encoderConfiguration
    }
    
    private func dereference(_ model: TypeInformation) -> TypeInformation {
        switch model {
        case .scalar, .enum: return model
        case let .repeated(element): return .repeated(element: dereference(element))
        case let .dictionary(key, value): return .dictionary(key: key, value: dereference(value))
        case let .optional(wrappedValue): return .optional(wrappedValue: dereference(wrappedValue))
        case let .object(name, properties, _):
            return .object(name: name, properties: properties.map { .init(name: $0.name, type: dereference($0.type), annotation: $0.annotation) })
        case let .reference(key):
            if let type = models.first(where: { $0.typeName.name == key.rawValue }) {
                return dereference(type)
            }
            fatalError("Something went fundamentally wrong. Did not find the corresponding model of the reference with key: \(key.rawValue)")
        }
    }
    
    private func method(for model: TypeInformation) -> String {
        let typeName = model.typeName.name
        let jsonString: String
        if let jsonValue = objectJSONs[typeName] {
            jsonString = jsonValue.rawValue
        } else {
            jsonString = JSONStringBuilder.jsonString(dereference(model), with: encoderConfiguration)
        }
        
        let returnValue =
        """
        func test\(typeName)() throws {
        let json: JSONValue =
        \"""
        \(jsonString)
        \"""
        
        let instance = XCTAssertNoThrowWithResult(try \(typeName).instance(from: json))
        XCTAssertNoThrow(try \(typeName).encoder.encode(instance))
        }
        """
        
        return returnValue
    }
    
    public func render() -> String {
        """
        \(FileHeaderComment(fileName: fileName + .swift).render())
        
        \(Import(.xCTest).render())
        @testable import \(packageName)
        @testable \(Import(.apodiniMigratorClientSupport).render())

        final class \(packageName)Tests: XCTestCase {
        \(models.map { method(for: $0) }.joined(separator: .doubleLineBreak))

        func XCTAssertNoThrowWithResult<T>(_ expression: @autoclosure () throws -> T) -> T {
        XCTAssertNoThrow(try expression())
        do {
        return try expression()
        } catch {
        preconditionFailure(\"Expression threw an error: \\(error.localizedDescription)\")
        }
        }
        }
        """
    }
}
