//
//  TestFileTemplate.swift
//  ApodiniMigratorGenerator
//
//  Created by Eldi Cano on 27.06.21.
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
        self.models = models
        self.fileName = fileName
        self.packageName = packageName
        self.objectJSONs = objectJSONs
        self.encoderConfiguration = encoderConfiguration
    }
    
    private func method(for model: TypeInformation) -> String {
        let typeName = model.typeName.name
        let jsonString: String
        if let jsonValue = objectJSONs[typeName] {
            jsonString = jsonValue.rawValue
        } else {
            jsonString = JSONStringBuilder.jsonString(model, with: encoderConfiguration)
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
