//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorCompare

// swiftlint:disable:next type_body_length
final class EndpointComparatorTests: ApodiniMigratorXCTestCase {
    var endpointChanges = [EndpointChange]()

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        endpointChanges.removeAll()
    }

    struct LHSResponse: ApodiniMigratorCodable {
        static var encoder: JSONEncoder = .init()
        static var decoder: JSONDecoder = .init()
        
        let id: UUID
        let name: String
        let age: Int
    }
    
    struct RHSResponse: ApodiniMigratorCodable {
        static var encoder: JSONEncoder = .init()
        static var decoder: JSONDecoder = .init()
        
        let identifier: UUID
        let name: String
    }
    
    private let lhs = Endpoint(
        handlerName: "handlerName",
        deltaIdentifier: "test",
        operation: .read,
        communicationalPattern: .requestResponse,
        absolutePath: "/v1/tests/{second}",
        parameters: [
            .init(name: "isRunning", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: false),
            .init(name: "first", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: true),
            .init(name: "second", typeInformation: .scalar(.uuid), parameterType: .path, isRequired: true),
            // swiftlint:disable:next force_try
            .init(name: "third", typeInformation: try! TypeInformation(type: TestTypes.Car.self), parameterType: .content, isRequired: true)
        ],
        // swiftlint:disable:next force_try
        response: try! TypeInformation(type: LHSResponse.self),
        errors: []
    )
    
    func testNoEndpointChange() throws {
        let comparator = EndpointComparator(lhs: lhs, rhs: lhs)
        comparator.compare(comparisonContext, &endpointChanges)
        XCTAssert(endpointChanges.isEmpty)
    }
    
    func testOperationChanged() throws {
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: .create,
            communicationalPattern: .requestResponse,
            absolutePath: lhs.identifier(for: EndpointPath.self).description,
            parameters: lhs.parameters,
            response: lhs.response,
            errors: lhs.errors
        )

        let comparator = EndpointComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &endpointChanges)

        XCTAssertEqual(endpointChanges.count, 1)
        let change = try XCTUnwrap(endpointChanges.first)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .identifier(identifierChange) = updateChange.updated else {
            XCTFail("Change did not store the updated operation")
            return
        }

        XCTAssertEqual(identifierChange.type, .update)
        XCTAssertEqual(change.breaking, identifierChange.breaking)
        XCTAssertEqual(change.solvable, identifierChange.solvable)
        XCTAssertEqual(identifierChange.id.rawValue, Operation.identifierType)
        let operationUpdate = try XCTUnwrap(identifierChange.modeledUpdateChange)
        XCTAssertEqual(operationUpdate.updated.to.typed(), Operation.create)
    }
    
    func testResourcePathChange() throws {
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: .read,
            communicationalPattern: lhs.communicationalPattern,
            absolutePath: "/v1/newTests/{second}",
            parameters: lhs.parameters,
            response: lhs.response,
            errors: lhs.errors
        )

        let comparator = EndpointComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &endpointChanges)

        XCTAssertEqual(endpointChanges.count, 1)
        let change = try XCTUnwrap(endpointChanges.first)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .identifier(identifierChange) = updateChange.updated else {
            XCTFail("Change did not store the updated resource path")
            return
        }
        XCTAssertEqual(identifierChange.type, .update)
        XCTAssertEqual(change.breaking, identifierChange.breaking)
        XCTAssertEqual(change.solvable, identifierChange.solvable)
        XCTAssertEqual(identifierChange.id.rawValue, EndpointPath.identifierType)
        let pathChange = try XCTUnwrap(identifierChange.modeledUpdateChange)
        XCTAssertEqual(pathChange.updated.to.typed(of: EndpointPath.self), rhs.identifier())
    }

    func testCommunicationPatternChange() throws {
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: lhs.operation,
            communicationalPattern: .bidirectionalStream,
            absolutePath: lhs.path.description,
            parameters: lhs.parameters,
            response: lhs.response,
            errors: lhs.errors
        )

        let comparator = EndpointComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &endpointChanges)

        XCTAssertEqual(endpointChanges.count, 1)
        let change = try XCTUnwrap(endpointChanges.first)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .communicationalPattern(from, to) = updateChange.updated else {
            XCTFail("Change did not store the updated communicational pattern")
            return
        }

        XCTAssertEqual(from, .requestResponse)
        XCTAssertEqual(to, .bidirectionalStream)
    }
    
    func testAddNewEndpointParameter() throws {
        let newParameter = Parameter(name: "newParam", typeInformation: .scalar(.int64), parameterType: .lightweight, isRequired: true)
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: lhs.identifier(),
            communicationalPattern: .requestResponse,
            absolutePath: lhs.identifier(for: EndpointPath.self).description,
            parameters: lhs.parameters + newParameter,
            response: lhs.response,
            errors: lhs.errors
        )

        let comparator = EndpointComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &endpointChanges)

        XCTAssertEqual(endpointChanges.count, 1)
        let change = try XCTUnwrap(endpointChanges.first)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .parameter(parameterChange) = updateChange.updated else {
            XCTFail("Change did not store the updated property")
            return
        }

        XCTAssertEqual(parameterChange.type, .addition)
        XCTAssertEqual(change.breaking, parameterChange.breaking)
        XCTAssertEqual(change.solvable, parameterChange.solvable)
        XCTAssertEqual(parameterChange.id, newParameter.deltaIdentifier)
        let parameterAddition = try XCTUnwrap(parameterChange.modeledAdditionChange)
        XCTAssertEqual(parameterAddition.added, newParameter)

        if let jsonId = parameterAddition.defaultValue,
           let json = comparisonContext.jsonValues[jsonId] {
            let instance = XCTAssertNoThrowWithResult(try Int64.instance(from: json))
            XCTAssertEqual(instance, 0)
        } else {
            XCTFail("No default value provided for added required parameter")
        }
    }
    
    func testDeleteEndpointParameter() throws {
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: lhs.identifier(),
            communicationalPattern: .requestResponse,
            absolutePath: lhs.identifier(for: EndpointPath.self).description,
            parameters: lhs.parameters.filter { $0.name != "first" },
            response: lhs.response,
            errors: lhs.errors
        )

        let comparator = EndpointComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &endpointChanges)

        XCTAssertEqual(endpointChanges.count, 1)
        let change = try XCTUnwrap(endpointChanges.first)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, false)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .parameter(parameterChange) = updateChange.updated else {
            XCTFail("Change did not store the updated property")
            return
        }

        XCTAssertEqual(parameterChange.type, .removal)
        XCTAssertEqual(change.breaking, parameterChange.breaking)
        XCTAssertEqual(change.solvable, parameterChange.solvable)
        XCTAssertEqual(parameterChange.id, "first")

        let parameterRemoval = try XCTUnwrap(parameterChange.modeledRemovalChange)
        XCTAssertEqual(parameterRemoval.removed, nil)
        XCTAssertEqual(parameterRemoval.fallbackValue, nil, "Provided a non necessary fallback value for a deleted endpoint parameter")
    }
    
    func testRenamedEndpointParameter() throws {
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: lhs.identifier(),
            communicationalPattern: .requestResponse,
            absolutePath: lhs.identifier(for: EndpointPath.self).description,
            parameters: [
                .init(name: "isRunning", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: false),
                .init(name: "firstParam", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: true),
                .init(name: "second", typeInformation: .scalar(.uuid), parameterType: .path, isRequired: true),
                .init(name: "third", typeInformation: try TypeInformation(type: TestTypes.Car.self), parameterType: .content, isRequired: true)
            ],
            response: lhs.response,
            errors: lhs.errors
        )

        let comparator = EndpointComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &endpointChanges)

        XCTAssertEqual(endpointChanges.count, 1)
        let change = try XCTUnwrap(endpointChanges.first)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .parameter(parameterChange) = updateChange.updated else {
            XCTFail("Change did not store the updated property")
            return
        }

        XCTAssertEqual(parameterChange.type, .idChange)
        XCTAssertEqual(change.breaking, parameterChange.breaking)
        XCTAssertEqual(change.solvable, parameterChange.solvable)
        XCTAssertEqual(parameterChange.id, "first")

        let parameterRename = try XCTUnwrap(parameterChange.modeledIdentifierChange)
        XCTAssertEqual(parameterChange.id, parameterRename.from)
        XCTAssertEqual(parameterRename.to, "firstParam")
        XCTAssert(try XCTUnwrap(parameterRename.similarity) > 0.5)
    }
    
    func testEndpointParameterNecessityChange() throws {
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: lhs.identifier(),
            communicationalPattern: .requestResponse,
            absolutePath: lhs.identifier(for: EndpointPath.self).description,
            parameters: [
                .init(name: "isRunning", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: true),
                .init(name: "first", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: true),
                .init(name: "second", typeInformation: .scalar(.uuid), parameterType: .path, isRequired: true),
                .init(name: "third", typeInformation: try TypeInformation(type: TestTypes.Car.self), parameterType: .content, isRequired: true)
            ],
            response: lhs.response,
            errors: lhs.errors
        )

        let comparator = EndpointComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &endpointChanges)

        XCTAssertEqual(endpointChanges.count, 1)
        let change = try XCTUnwrap(endpointChanges.first)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .parameter(parameterChange) = updateChange.updated else {
            XCTFail("Change did not store the updated parameter")
            return
        }

        XCTAssertEqual(parameterChange.type, .update)
        XCTAssertEqual(change.breaking, parameterChange.breaking)
        XCTAssertEqual(change.solvable, parameterChange.solvable)
        XCTAssertEqual(parameterChange.id, "isRunning")

        let parameterUpdate = try XCTUnwrap(parameterChange.modeledUpdateChange)
        guard case let .necessity(from, to, necessityMigration) = parameterUpdate.updated else {
            XCTFail("Unexpected parameter update change: \(parameterUpdate.updated)")
            return
        }
        XCTAssertEqual(from, .optional)
        XCTAssertEqual(to, .required)

        if let json = comparisonContext.jsonValues[necessityMigration] {
            let instance = XCTAssertNoThrowWithResult(try String.instance(from: json))
            XCTAssertEqual(instance, "")
        }
    }
    
    func testEndpointParameterKindChange() throws {
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: lhs.identifier(),
            communicationalPattern: .requestResponse,
            // removing from path as well
            absolutePath: lhs.identifier(for: EndpointPath.self).description.replacingOccurrences(of: "{second}", with: ""),
            parameters: [
                .init(name: "isRunning", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: false),
                .init(name: "first", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: true),
                .init(name: "second", typeInformation: .scalar(.uuid), parameterType: .lightweight, isRequired: true),
                .init(name: "third", typeInformation: try TypeInformation(type: TestTypes.Car.self), parameterType: .content, isRequired: true)
            ],
            response: lhs.response,
            errors: lhs.errors
        )

        let comparator = EndpointComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &endpointChanges)

        XCTAssertEqual(endpointChanges.count, 2) // registered two changes, one for the path as well
        let change = try XCTUnwrap(endpointChanges.last)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .parameter(parameterChange) = updateChange.updated else {
            XCTFail("Change did not store the updated parameter: \(updateChange.updated)")
            return
        }

        XCTAssertEqual(parameterChange.type, .update)
        XCTAssertEqual(change.breaking, parameterChange.breaking)
        XCTAssertEqual(change.solvable, parameterChange.solvable)
        XCTAssertEqual(parameterChange.id, "second")

        let parameterUpdate = try XCTUnwrap(parameterChange.modeledUpdateChange)
        guard case let .parameterType(from, to) = parameterUpdate.updated else {
            XCTFail("Unexpected parameter update change: \(parameterUpdate.updated)")
            return
        }
        XCTAssertEqual(from, .path)
        XCTAssertEqual(to, .lightweight)
    }
    
    func testEndpointParameterTypeChange() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: lhs.identifier(),
            communicationalPattern: .requestResponse,
            absolutePath: lhs.identifier(for: EndpointPath.self).description,
            parameters: [
                .init(name: "isRunning", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: false),
                .init(name: "first", typeInformation: .scalar(.bool), parameterType: .lightweight, isRequired: true),
                .init(name: "second", typeInformation: .scalar(.uuid), parameterType: .path, isRequired: true),
                .init(name: "third", typeInformation: try TypeInformation(type: TestTypes.Car.self), parameterType: .content, isRequired: true)
            ],
            response: lhs.response,
            errors: lhs.errors
        )

        let comparator = EndpointComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &endpointChanges)

        XCTAssertEqual(endpointChanges.count, 1)
        let change = try XCTUnwrap(endpointChanges.first)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .parameter(parameterChange) = updateChange.updated else {
            XCTFail("Change did not store the updated parameter")
            return
        }

        XCTAssertEqual(parameterChange.type, .update)
        XCTAssertEqual(change.breaking, parameterChange.breaking)
        XCTAssertEqual(change.solvable, parameterChange.solvable)
        XCTAssertEqual(parameterChange.id, "first")

        let parameterUpdate = try XCTUnwrap(parameterChange.modeledUpdateChange)
        guard case let .type(from, to, forwardMigration, conversionWarning) = parameterUpdate.updated else {
            XCTFail("Unexpected parameter update change: \(parameterUpdate.updated)")
            return
        }
        XCTAssertEqual(from, .scalar(.string))
        XCTAssertEqual(to, .scalar(.bool))
        XCTAssertEqual(conversionWarning, nil)

        if let script = comparisonContext.scripts[forwardMigration] {
            XCTAssertNoThrow(try Bool.from("", script: script), "Invalid script to convert string to bool")
        }
    }
    
    func testEndpointResponseChange() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: .read,
            communicationalPattern: .requestResponse,
            absolutePath: lhs.identifier(for: EndpointPath.self).description,
            parameters: lhs.parameters,
            response: try TypeInformation(type: RHSResponse.self),
            errors: lhs.errors
        )

        let comparator = EndpointComparator(lhs: lhs, rhs: rhs)
        comparator.compare(comparisonContext, &endpointChanges)

        XCTAssertEqual(endpointChanges.count, 1)
        let change = try XCTUnwrap(endpointChanges.first)
        XCTAssertEqual(change.id, lhs.deltaIdentifier)
        XCTAssertEqual(change.type, .update)
        XCTAssertEqual(change.breaking, true)
        XCTAssertEqual(change.solvable, true)
        let updateChange = try XCTUnwrap(change.modeledUpdateChange)

        guard case let .response(from, to, backwardsConversion, conversionWarning) = updateChange.updated else {
            XCTFail("Change did not store the updated parameter")
            return
        }
        XCTAssertEqual(from, .reference("EndpointComparatorTests.LHSResponse"))
        XCTAssertEqual(to, .reference("EndpointComparatorTests.RHSResponse"))
        XCTAssertEqual(conversionWarning, nil)

        if let script = comparisonContext.scripts[backwardsConversion] {
            let id = UUID()
            let instance = XCTAssertNoThrowWithResult(try LHSResponse.from(RHSResponse(identifier: id, name: "someResponse"), script: script))
            XCTAssertEqual(instance.id, id)
            XCTAssertEqual(instance.name, "someResponse")
            XCTAssertEqual(instance.age, 0)
        }
    }
}
