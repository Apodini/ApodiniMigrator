//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import ApodiniMigrator
@testable import ApodiniMigratorCompare
import PathKit
import MigratorAPI

final class EndpointMigratorTests: ApodiniMigratorXCTestCase {
    private let endpoint = Endpoint(
        handlerName: "TestHandler",
        deltaIdentifier: "testEndpoint",
        operation: .read,
        absolutePath: "/v1/tests/{second}",
        parameters: [
            .init(name: "isDriving", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: false),
            .init(name: "first", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: true),
            .init(name: "second", typeInformation: .scalar(.uuid), parameterType: .path, isRequired: true),
            .init(name: "third", typeInformation: try! TypeInformation(type: TestTypes.Car.self), parameterType: .content, isRequired: true)
        ],
        response: .reference("TestResponse"),
        errors: [.init(code: 404, message: "Not found")]
    )
    
    private var pathChange: UpdateChange {
        .init(
            element: .endpoint(endpoint.deltaIdentifier, target: .resourcePath),
            from: .element(endpoint.path),
            to: .element(EndpointPath("/v1/updatedTests/{second}")),
            breaking: true,
            solvable: true
        )
    }
    
    private var operationChange: UpdateChange {
        .init(
            element: .endpoint(endpoint.deltaIdentifier, target: .operation),
            from: .element(endpoint.operation),
            to: .element(ApodiniMigratorCore.Operation.create),
            breaking: true,
            solvable: true
        )
    }

    private var addParameterChange: AddChange {
        .init(
            element: .endpoint(endpoint.deltaIdentifier, target: .queryParameter),
            added: .element(Parameter(name: "newParameter", typeInformation: .scalar(.bool), parameterType: .lightweight, isRequired: true)),
            defaultValue: .json(123),
            breaking: true,
            solvable: true
        )
    }
  
    private var deleteParameterChange: DeleteChange {
        .init(
            element: .endpoint(endpoint.deltaIdentifier, target: .queryParameter),
            deleted: .elementID("first"),
            fallbackValue: .none,
            breaking: false,
            solvable: true
        )
    }
    
    private var deleteContentParameterChange: DeleteChange {
        .init(
            element: .endpoint(endpoint.deltaIdentifier, target: .queryParameter),
            deleted: .elementID("third"),
            fallbackValue: .none,
            breaking: false,
            solvable: true
        )
    }
    
    private var renamedParameterChange: UpdateChange {
        .init(
            element: .endpoint(endpoint.deltaIdentifier, target: .queryParameter),
            from: "first",
            to: "someNewParameterName",
            similarity: 0,
            breaking: true,
            solvable: true
        )
    }
    
    private var pathAndParameterKindChanges: [Change] {
        [
            UpdateChange(
                element: .endpoint(endpoint.deltaIdentifier, target: .queryParameter),
                from: .element(ParameterType.lightweight),
                to: .element(ParameterType.path),
                targetID: "first",
                parameterTarget: .kind,
                breaking: true,
                solvable: true
            ),
            UpdateChange(
                element: .endpoint(endpoint.deltaIdentifier, target: .resourcePath),
                from: .element(endpoint.path),
                to: .element(EndpointPath("/v1/tests/{second}/{first}")),
                breaking: true,
                solvable: true
            )
        ]
    }
    
    private var parameterTypeChange: UpdateChange {
        UpdateChange(
            element: .endpoint(endpoint.deltaIdentifier, target: .queryParameter),
            from: .element(TypeInformation.scalar(.string)),
            to: .element(TypeInformation.scalar(.bool)),
            targetID: "first",
            convertFromTo: 1,
            convertionWarning: nil,
            parameterTarget: .typeInformation,
            breaking: true,
            solvable: true
        )
    }
        
    private var parameterNecessityToRequiredChange: UpdateChange {
        .init(
            element: .endpoint(endpoint.deltaIdentifier, target: .queryParameter),
            from: .element(Necessity.optional),
            to: .element(Necessity.required),
            targetID: "isDriving",
            necessityValue: .json(1),
            parameterTarget: .necessity,
            breaking: true,
            solvable: true
        )
    }
    
    private var parameterNecessityToOptionalChange: UpdateChange {
        .init(
            element: .endpoint(endpoint.deltaIdentifier, target: .queryParameter),
            from: .element(Necessity.required),
            to: .element(Necessity.optional),
            targetID: "name",
            parameterTarget: .necessity,
            breaking: true,
            solvable: true
        )
    }
    
    private var responseChange: UpdateChange {
        .init(
            element: .endpoint(endpoint.deltaIdentifier, target: .queryParameter),
            from: .element(endpoint.response),
            to: .element(TypeInformation.reference("UpdatedTestResponse")),
            convertToFrom: 1,
            convertionWarning: nil,
            breaking: true,
            solvable: true
        )
    }
    
    override class func setUp() {
        super.setUp()
        
        FileHeaderComment.testsDate = .testsDate
    }
    
    private func endpointFile(changes: [Change]) -> EndpointFile {
        // TODO find a shorter way to do this LOL
        @SharedNodeStorage
        var migratedEndpoints: [MigratedEndpoint]
        @SharedNodeReference
        var reference: [MigratedEndpoint]
        _reference = $migratedEndpoints
        reference = []

        return .init(migratedEndpointsReference: $migratedEndpoints, typeInformation: endpoint.response, endpoints: [endpoint], changes: changes)
    }
    
    func testDefaultEndpointFile() throws {
        let file = endpointFile(changes: [])
        
        XCTMigratorAssertEqual(file, .defaultEndpointFile)
    }
    
    func testEndpointPathChange() throws {
        let file = endpointFile(changes: [pathChange])
        
        XCTMigratorAssertEqual(file, .endpointPathChange)
    }
    
    func testEndpointOperationChange() throws {
        let file = endpointFile(changes: [operationChange])
        
        XCTMigratorAssertEqual(file, .endpointOperationChange)
    }
    
    func testAddEndpointParameterChange() throws {
        let file = endpointFile(changes: [addParameterChange])
        
        XCTMigratorAssertEqual(file, .endpointAddParameterChange)
    }
    
    func testDeleteEndpointParameterChange() throws {
        let file = endpointFile(changes: [deleteParameterChange])
        
        XCTMigratorAssertEqual(file, .endpointDeleteParameterChange)
    }
    
    func testDeleteEndpointContentParameterChange() throws {
        let file = endpointFile(changes: [deleteContentParameterChange])
        
        XCTMigratorAssertEqual(file, .endpointDeleteContentParameterChange)
    }
    
    func testRenameEndpointParameterChange() throws {
        let file = endpointFile(changes: [renamedParameterChange])
        
        XCTMigratorAssertEqual(file, .endpointRenameParameterChange)
    }
    
    func testParameterNecessityToRequiredChange() throws {
        let file = endpointFile(changes: [parameterNecessityToRequiredChange])
        
        XCTMigratorAssertEqual(file, .endpointParameterNecessityToRequiredChange)
    }
    
    func testParameterNecessityToOptionalChange() throws {
        let file = endpointFile(changes: [parameterNecessityToOptionalChange])
        
        XCTMigratorAssertEqual(file, .defaultEndpointFile) // no update to the method required for this change
    }
    
    func testParameterKindAndPathChange() throws {
        let file = endpointFile(changes: pathAndParameterKindChanges)
        
        XCTMigratorAssertEqual(file, .endpointParameterKindAndPathChange)
    }
    
    func testParameterTypeChange() throws {
        let file = endpointFile(changes: [parameterTypeChange])
        
        XCTMigratorAssertEqual(file, .endpointParameterTypeChange)
    }
    
    func testEndpointResponseChange() throws {
        let file = endpointFile(changes: [responseChange])

        XCTMigratorAssertEqual(file, .endpointResponseChange)
    }
    
    func testEndpointMultipleChanges() throws {
        let file = endpointFile(
            changes: [
                addParameterChange,
                deleteContentParameterChange,
                pathAndParameterKindChanges.first,
                pathAndParameterKindChanges.last
            ].compactMap { $0 }
        )
        
        XCTMigratorAssertEqual(file, .endpointMultipleChanges)
    }
    
    func testEndpointDeletedChange() throws {
        let deletedSelfChange = DeleteChange(
            element: .endpoint(endpoint.deltaIdentifier, target: .`self`),
            deleted: .elementID(endpoint.deltaIdentifier),
            fallbackValue: .none,
            breaking: true,
            solvable: true
        )
        
        let file = endpointFile(changes: [deletedSelfChange])
        
        XCTMigratorAssertEqual(file, .endpointDeletedChange)
    }
}
