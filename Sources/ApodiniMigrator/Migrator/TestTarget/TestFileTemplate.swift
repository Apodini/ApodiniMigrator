//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigratorClientSupport
import ApodiniMigratorShared
import MigratorAPI

// TODO rename
struct TestFileTemplate: GeneratedFile {
    let fileName: [NameComponent]
    let models: [TypeInformation]
    let objectJSONs: [String: JSONValue]
    let encoderConfiguration: EncoderConfiguration
    
    public init(
        name: NameComponent...,
        models: [TypeInformation],
        objectJSONs: [String: JSONValue] = [:],
        encoderConfiguration: EncoderConfiguration = .default
    ) {
        self.fileName = name
        self.models = models.sorted(by: \.typeString)
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


        @FileCodeStringBuilder
        var method: String {
            "func test\(typeName)() throws {"
            Indent {
                // TODO jsonString isn't indented
                """
                let json: JSONValue =
                \"""
                \(jsonString)
                \"""

                let instance = XCTAssertNoThrowWithResult(try \(typeName).instance(from: json))
                XCTAssertNoThrow(try \(typeName).encoder.encode(instance))
                """
            }
            "}"
        }

        return method
    }

    var fileContent: String {
        FileHeaderComment()

        Import(.xCTest)
        Import("\(GlobalPlaceholder.$packageName)", testable: true)
        Import(.apodiniMigratorClientSupport, testable: true)
        ""

        "final class \(GlobalPlaceholder.$packageName)Tests: XCTestCase {"
        Indent {
            for model in models {
                method(for: model)
                ""
            }

            "func XCTAssertNoThrowWithResult<T>(_ expression: @autoclosure () throws -> T) -> T {"
            Indent {
                "XCTAssertNoThrow(try expression())"
                "do {"
                Indent {
                    "return try expression()"
                }
                "} catch {"
                Indent {
                    "preconditionFailure(\"Expression threw an error: \\(error.localizedDescription)\")"
                }
                "}"
            }
            "}"
        }
        "}"
    }
}
