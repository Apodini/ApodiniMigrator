//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorCompare

final class AnyCodableAndRelaxedIdentifiableTests: ApodiniMigratorXCTestCase {
    func testAnyCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let document = try Documents.v1.decodedContent() as Document
        let documentAsAnyCodable = document.asAnyCodableElement
        let documentData = XCTAssertNoThrowWithResult(try encoder.encode(documentAsAnyCodable))
        XCTAssertNoThrow(try decoder.decode(AnyCodableElement.self, from: documentData))
        
        let deltaIdentifier: DeltaIdentifier = "id"
        let deltaIdentifierData = XCTAssertNoThrowWithResult(try encoder.encode(deltaIdentifier.asAnyCodableElement))
        XCTAssertNoThrow(try decoder.decode(AnyCodableElement.self, from: deltaIdentifierData))
        
        let endpoint = document.endpoints[0]
        let endpointData = XCTAssertNoThrowWithResult(try encoder.encode(endpoint.asAnyCodableElement))
        XCTAssertNoThrow(try decoder.decode(AnyCodableElement.self, from: endpointData))
        
        let path = endpoint.path
        let pathData = XCTAssertNoThrowWithResult(try encoder.encode(path.asAnyCodableElement))
        XCTAssertNoThrow(try decoder.decode(AnyCodableElement.self, from: pathData))
        
        let parameter = Parameter(name: "", typeInformation: .scalar(.bool), parameterType: .content, isRequired: true)
        let parameterData = XCTAssertNoThrowWithResult(try encoder.encode(parameter.asAnyCodableElement))
        XCTAssertNoThrow(try decoder.decode(AnyCodableElement.self, from: parameterData))
        
        let typeInformation = parameter.typeInformation
        let typeInformationData = XCTAssertNoThrowWithResult(try encoder.encode(typeInformation.asAnyCodableElement))
        XCTAssertNoThrow(try decoder.decode(AnyCodableElement.self, from: typeInformationData))
        
        let encoderConfig = document.metaData.encoderConfiguration
        let encoderConfigData = XCTAssertNoThrowWithResult(try encoder.encode(encoderConfig.asAnyCodableElement))
        XCTAssertNoThrow(try decoder.decode(AnyCodableElement.self, from: encoderConfigData))
        
        let decoderConfig = document.metaData.decoderConfiguration
        let decoderConfigData = XCTAssertNoThrowWithResult(try encoder.encode(decoderConfig.asAnyCodableElement))
        XCTAssertNoThrow(try decoder.decode(AnyCodableElement.self, from: decoderConfigData))
        
        let operation = endpoint.operation
        let operationData = XCTAssertNoThrowWithResult(try encoder.encode(operation.asAnyCodableElement))
        XCTAssertNoThrow(try decoder.decode(AnyCodableElement.self, from: operationData))
        
        let necessity = parameter.necessity
        let necessityData = XCTAssertNoThrowWithResult(try encoder.encode(necessity.asAnyCodableElement))
        XCTAssertNoThrow(try decoder.decode(AnyCodableElement.self, from: necessityData))
        
        let parameterType = parameter.parameterType
        let parameterTypeData = XCTAssertNoThrowWithResult(try encoder.encode(parameterType.asAnyCodableElement))
        XCTAssertNoThrow(try decoder.decode(AnyCodableElement.self, from: parameterTypeData))
        
        let typeProperty = TypeProperty(name: "", type: .scalar(.bool))
        let typePropertyData = XCTAssertNoThrowWithResult(try encoder.encode(typeProperty.asAnyCodableElement))
        XCTAssertNoThrow(try decoder.decode(AnyCodableElement.self, from: typePropertyData))
        
        let enumCase = EnumCase("")
        let enumCaseData = XCTAssertNoThrowWithResult(try encoder.encode(enumCase.asAnyCodableElement))
        XCTAssertNoThrow(try decoder.decode(AnyCodableElement.self, from: enumCaseData))
        
        let anyCodableSet: Set<AnyCodableElement> = [documentAsAnyCodable]
        XCTAssert(anyCodableSet.first?.description.contains(document.id.uuidString) == true)
        
        XCTAssertEqual(AnyCodableElement(deltaIdentifier), deltaIdentifier.asAnyCodableElement)
    }
    
    func testRelaxedDeltaIdentifiable() {
        let int = TypeName(Int.self)
        let string = TypeName(String.self)
        let customInt = TypeName(name: "Int")
        
        XCTAssertEqual(int ?= string, false)
        XCTAssertEqual(int ?= customInt, false)
        XCTAssert(int ?= int)
        
        let reference = TypeInformation.reference("User")
        XCTAssert(reference.deltaIdentifier.rawValue == "User")
        XCTAssert(reference ?= .object(name: .init(name: "User"), properties: []))
    }
}
