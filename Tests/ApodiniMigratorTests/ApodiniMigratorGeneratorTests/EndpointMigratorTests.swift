//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import RESTMigrator
@testable import ApodiniMigrator
@testable import ApodiniMigratorCompare

final class EndpointMigratorTests: ApodiniMigratorXCTestCase {
    private let endpoint = Endpoint(
        handlerName: "TestHandler",
        deltaIdentifier: "testEndpoint",
        operation: .read,
        communicationalPattern: .requestResponse,
        absolutePath: "/v1/tests/{second}",
        parameters: [
            .init(name: "isDriving", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: false),
            .init(name: "first", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: true),
            .init(name: "second", typeInformation: .scalar(.uuid), parameterType: .path, isRequired: true),
            // swiftlint:disable:next force_try
            .init(name: "third", typeInformation: try! TypeInformation(type: TestTypes.Car.self), parameterType: .content, isRequired: true)
        ],
        response: .reference("TestResponse"),
        errors: [.init(code: 404, message: "Not found")]
    )
    
    private var pathChange: EndpointChange {
        .update(
            id: endpoint.deltaIdentifier,
            updated: .identifier(identifier: .update(
                id: .init(EndpointPath.identifierType),
                updated: .init(
                    from: AnyEndpointIdentifier(from: endpoint.identifier(for: EndpointPath.self)),
                    to: AnyEndpointIdentifier(from: EndpointPath(rawValue: "/v1/updatedTests/{second}"))
                ),
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }
    
    private var operationChange: EndpointChange {
        .update(
            id: endpoint.deltaIdentifier,
            updated: .identifier(identifier: .update(
                id: .init(Operation.identifierType),
                updated: .init(
                    from: AnyEndpointIdentifier(from: endpoint.identifier(for: ApodiniMigratorCore.Operation.self)),
                    to: AnyEndpointIdentifier(from: ApodiniMigratorCore.Operation.create)
                ),
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }

    private var addParameterChange: EndpointChange {
        .update(
            id: endpoint.deltaIdentifier,
            updated: .parameter(parameter: .addition(
                id: "newParameter",
                added: Parameter(name: "newParameter", typeInformation: .scalar(.bool), parameterType: .lightweight, isRequired: true),
                defaultValue: 123,
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }
  
    private var deleteParameterChange: EndpointChange {
        .update(
            id: endpoint.deltaIdentifier,
            updated: .parameter(parameter: .removal(
                id: "first",
                fallbackValue: nil,
                breaking: false,
                solvable: true
            )),
            breaking: false,
            solvable: true
        )
    }
    
    private var deleteContentParameterChange: EndpointChange {
        .update(
            id: endpoint.deltaIdentifier,
            updated: .parameter(parameter: .removal(
                id: "third",
                fallbackValue: nil,
                breaking: false,
                solvable: true
            )),
            breaking: false,
            solvable: true
        )
    }
    
    private var renamedParameterChange: EndpointChange {
        .update(
            id: endpoint.deltaIdentifier,
            updated: .parameter(parameter: .idChange(
                from: "first",
                to: "someNewParameterName",
                similarity: 0,
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }
    
    private var pathAndParameterKindChanges: [EndpointChange] {
        [
            .update(
                id: endpoint.deltaIdentifier,
                updated: .parameter(parameter: .update(
                    id: "first",
                    updated: .parameterType(from: .lightweight, to: .path),
                    breaking: true,
                    solvable: true
                )),
                breaking: true,
                solvable: true
            ),
            .update(
                id: endpoint.deltaIdentifier,
                updated: .identifier(identifier: .update(
                    id: .init(EndpointPath.identifierType),
                    updated: .init(
                        from: AnyEndpointIdentifier(from: endpoint.identifier(for: EndpointPath.self)),
                        to: AnyEndpointIdentifier(from: EndpointPath(rawValue: "/v1/tests/{second}/{first}"))
                    ),
                    breaking: true,
                    solvable: true
                )),
                breaking: true,
                solvable: true
            )
        ]
    }
    
    private var parameterTypeChange: EndpointChange {
        .update(
            id: endpoint.deltaIdentifier,
            updated: .parameter(parameter: .update(
                id: "first",
                updated: .type(
                    from: .scalar(.string),
                    to: .scalar(.bool),
                    forwardMigration: 1,
                    conversionWarning: nil
                ),
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }
        
    private var parameterNecessityToRequiredChange: EndpointChange {
        .update(
            id: endpoint.deltaIdentifier,
            updated: .parameter(parameter: .update(
                id: "isDriving",
                updated: .necessity(
                    from: .optional,
                    to: .required,
                    necessityMigration: 1
                ),
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }
    
    private var parameterNecessityToOptionalChange: EndpointChange {
        .update(
            id: endpoint.deltaIdentifier,
            updated: .parameter(parameter: .update(
                id: "name",
                updated: .necessity(
                    from: .required,
                    to: .optional,
                    necessityMigration: 0
                ),
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }
    
    private var responseChange: EndpointChange {
        .update(
            id: endpoint.deltaIdentifier,
            updated: .response(
                from: endpoint.response,
                to: .reference("UpdatedTestResponse"),
                backwardsMigration: 1,
                migrationWarning: nil
            ),
            breaking: true,
            solvable: true
        )
    }

    private var endpointRemovalChange: EndpointChange {
        .removal(
            id: endpoint.deltaIdentifier,
            fallbackValue: nil,
            breaking: true,
            solvable: true
        )
    }
    
    override class func setUp() {
        super.setUp()
        
        FileHeaderComment.testsDate = .testsDate
    }
    
    private func endpointFile(changes: [EndpointChange]) -> EndpointFile {
        EndpointFile(
            migratedEndpointsReference: SharedNodeReference(with: []),
            typeInformation: endpoint.response,
            endpoints: [endpoint],
            changes: changes
        )
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
        let file = endpointFile(changes: [endpointRemovalChange])
        
        XCTMigratorAssertEqual(file, .endpointDeletedChange)
    }

    func testWrappedContentParameter() throws {
        // TODO this doesn't test the migrationGuide Migration!
        let param1 = Parameter(name: "first", typeInformation: .scalar(.string), parameterType: .content, isRequired: true)
        let param2 = Parameter(name: "second", typeInformation: .scalar(.int), parameterType: .content, isRequired: false)

        var document = APIDocument(
            serviceInformation: .init(version: .default, http: HTTPInformation(hostname: "localhost", port: 80), exporters: [])
        )
        var migrationGuide: MigrationGuide = .empty(id: document.id)

        document.add(endpoint: Endpoint(
            handlerName: "someHandler",
            deltaIdentifier: "id",
            operation: .create,
            communicationalPattern: .requestResponse,
            absolutePath: "/v1/test",
            parameters: [param1, param2],
            response: .scalar(.bool),
            errors: []
        ))

        document.combineEndpointParametersIntoWrappedType(considering: &migrationGuide, using: RESTContentParameterCombination())

        let endpoint = try XCTUnwrap(document.endpoints.first)

        let file = EndpointFile(
            migratedEndpointsReference: SharedNodeReference(with: []),
            typeInformation: endpoint.response,
            endpoints: [endpoint],
            changes: []
        )

        XCTMigratorAssertEqual(file, .endpointWrappedContentParameter)
    }
}
