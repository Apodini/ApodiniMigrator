//
//  File.swift
//  
//
//  Created by Eldi Cano on 25.05.21.
//

import Foundation
import ApodiniMigratorClientSupport

public struct TestFileTemplate: Renderable {
    let models: [TypeInformation]
    let fileName: String
    let packageName: String
    
    public init(_ models: [TypeInformation], fileName: String, packageName: String) {
        self.models = models
        self.fileName = fileName
        self.packageName = packageName
    }
    
    
    private func method(for model: TypeInformation) -> String {
        """
        func test\(model.typeName.name)() throws {
        let jsonString = \"\(JSONStringBuilder.jsonString(model, with: .default).replacingOccurrences(of: "\"", with: "\\\""))\"
        let data = jsonString.data(using: .utf8) ?? Data()

        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(\(model.typeName.name).self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
        }
        """
    }
    
    public func render() -> String {
        """
        \(FileHeaderComment(fileName: fileName + .swift).render())
        
        \(Import(.xCTest).render())
        @testable import \(packageName)

        final class \(packageName)Tests: XCTestCase {
        \(MARKComment("Encoder - Decoder"))
        private static let encoder = NetworkingService.encoder
        private static let decoder = NetworkingService.decoder

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
