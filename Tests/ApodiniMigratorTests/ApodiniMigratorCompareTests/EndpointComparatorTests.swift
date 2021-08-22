import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorCompare

final class EndpointComparatorTests: ApodiniMigratorXCTestCase {
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
        absolutePath: "/v1/tests/{second}",
        parameters: [
            .init(name: "isRunning", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: false),
            .init(name: "first", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: true),
            .init(name: "second", typeInformation: .scalar(.uuid), parameterType: .path, isRequired: true),
            .init(name: "third", typeInformation: try! TypeInformation(type: TestTypes.Car.self), parameterType: .content, isRequired: true)
        ],
        response: try! TypeInformation(type: LHSResponse.self),
        errors: []
    )
    
    func testNoEndpointChange() throws {
        let endpointComparator = EndpointComparator(lhs: lhs, rhs: lhs, changes: node, configuration: .default)
        endpointComparator.compare()
        XCTAssert(node.isEmpty)
    }
    
    func testOperationChanged() throws {
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: .create,
            absolutePath: lhs.path.description,
            parameters: lhs.parameters,
            response: lhs.response,
            errors: lhs.errors
        )
        
        let endpointComparator = EndpointComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        endpointComparator.compare()
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? UpdateChange)
        XCTAssert(change.element == .endpoint("test", target: .operation))
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        if case let .element(codable) = change.to {
            XCTAssert(codable.typed(ApodiniMigratorCore.Operation.self) == .create)
        } else {
            XCTFail("Change did not store the updated operation")
        }
    }
    
    func testResourcePathChange() throws {
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: .read,
            absolutePath: "/v1/newTests/{second}",
            parameters: lhs.parameters,
            response: lhs.response,
            errors: lhs.errors
        )
        
        let endpointComparator = EndpointComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        endpointComparator.compare()
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? UpdateChange)
        XCTAssert(change.element == .endpoint("test", target: .resourcePath))
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        if case let .element(codable) = change.to {
            XCTAssert(codable.typed(EndpointPath.self) == rhs.path)
        } else {
            XCTFail("Change did not store the updated resource path")
        }
    }
    
    func testAddNewEndpointParameter() throws {
        let newParameter = Parameter(name: "newParam", typeInformation: .scalar(.int64), parameterType: .lightweight, isRequired: true)
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: lhs.operation,
            absolutePath: lhs.path.description,
            parameters: lhs.parameters + newParameter,
            response: lhs.response,
            errors: lhs.errors
        )
        
        let endpointComparator = EndpointComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        endpointComparator.compare()
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? AddChange)
        XCTAssert(change.element == .endpoint("test", target: .queryParameter))
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        if case let .element(codable) = change.added {
            XCTAssert(codable.typed(Parameter.self) == newParameter)
        } else {
            XCTFail("Change did not store the updated resource path")
        }
        
        if case let .json(id) = change.defaultValue, let json = node.jsonValues[id] {
            let defaultValue = XCTAssertNoThrowWithResult(try Int64.instance(from: json))
            XCTAssert(defaultValue == 0)
        } else {
            XCTFail("No default value provided for added required parameter")
        }
    }
    
    func testDeleteEndpointParameter() throws {
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: lhs.operation,
            absolutePath: lhs.path.description,
            parameters: lhs.parameters.filter { $0.name != "first" },
            response: lhs.response,
            errors: lhs.errors
        )
        
        let endpointComparator = EndpointComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        endpointComparator.compare()
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? DeleteChange)
        XCTAssert(change.element == .endpoint("test", target: .queryParameter))
        XCTAssert(!change.breaking)
        XCTAssert(change.solvable)
        if case let .elementID(id) = change.deleted {
            XCTAssert(id == .init("first"))
        } else {
            XCTFail("Change did not provide the id of the deleted parameter")
        }
        XCTAssert(change.fallbackValue == .none, "Provided a non necessary fallback value for a deleted endpoint parameter")
    }
    
    func testRenamedEndpointParameter() throws {
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: lhs.operation,
            absolutePath: lhs.path.description,
            parameters: [
                .init(name: "isRunning", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: false),
                .init(name: "firstParam", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: true),
                .init(name: "second", typeInformation: .scalar(.uuid), parameterType: .path, isRequired: true),
                .init(name: "third", typeInformation: try TypeInformation(type: TestTypes.Car.self), parameterType: .content, isRequired: true)
            ],
            response: lhs.response,
            errors: lhs.errors
        )
        
        let endpointComparator = EndpointComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        endpointComparator.compare()
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? UpdateChange)
        XCTAssert(change.element == .endpoint("test", target: .queryParameter))
        XCTAssert(change.type == .rename)
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        if case let .stringValue(value) = change.to, let similarity = change.similarity {
            XCTAssert(value == "firstParam")
            XCTAssert(similarity > 0.5)
        } else {
            XCTFail("Change did not provide the updated name of the parameter")
        }
    }
    
    func testEndpointParameterNecessityChange() throws {
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: lhs.operation,
            absolutePath: lhs.path.description,
            parameters: [
                .init(name: "isRunning", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: true),
                .init(name: "first", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: true),
                .init(name: "second", typeInformation: .scalar(.uuid), parameterType: .path, isRequired: true),
                .init(name: "third", typeInformation: try TypeInformation(type: TestTypes.Car.self), parameterType: .content, isRequired: true)
            ],
            response: lhs.response,
            errors: lhs.errors
        )
        
        let endpointComparator = EndpointComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        endpointComparator.compare()
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? UpdateChange)
        XCTAssert(change.element == .endpoint("test", target: .queryParameter))
        XCTAssert(change.parameterTarget == .necessity)
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        if case let .json(id) = change.necessityValue, let json = node.jsonValues[id] {
            let necessityValue = XCTAssertNoThrowWithResult(try String.instance(from: json))
            XCTAssert(necessityValue == "")
        } else {
            XCTFail("Change did not provide a necessity value for the required parameter")
        }
    }
    
    func testEndpointParameterKindChange() throws {
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: lhs.operation,
            absolutePath: lhs.path.description.without("{second}"), // removing from path as well
            parameters: [
                .init(name: "isRunning", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: false),
                .init(name: "first", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: true),
                .init(name: "second", typeInformation: .scalar(.uuid), parameterType: .lightweight, isRequired: true),
                .init(name: "third", typeInformation: try TypeInformation(type: TestTypes.Car.self), parameterType: .content, isRequired: true)
            ],
            response: lhs.response,
            errors: lhs.errors
        )
        
        let endpointComparator = EndpointComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        endpointComparator.compare()
        XCTAssert(node.changes.count == 2) // registered two changes, one for the path as well
        let change = try XCTUnwrap(node.changes.first(where: { $0.element.target == EndpointTarget.pathParameter.rawValue }) as? UpdateChange)
        XCTAssert(change.element == .endpoint("test", target: .pathParameter))
        XCTAssert(change.parameterTarget == .kind)
        XCTAssert(change.targetID == .init("second"))
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        if case let .element(codable) = change.to {
            XCTAssert(codable.typed(ParameterType.self) == .lightweight)
        } else {
            XCTFail("Change did not provide the updated kind of the parameter")
        }
    }
    
    func testEndpointParameterTypeChange() throws {
        guard canImportJavaScriptCore() else {
            return
        }
        let rhs = Endpoint(
            handlerName: lhs.handlerName,
            deltaIdentifier: lhs.deltaIdentifier.description,
            operation: lhs.operation,
            absolutePath: lhs.path.description,
            parameters: [
                .init(name: "isRunning", typeInformation: .scalar(.string), parameterType: .lightweight, isRequired: false),
                .init(name: "first", typeInformation: .scalar(.bool), parameterType: .lightweight, isRequired: true),
                .init(name: "second", typeInformation: .scalar(.uuid), parameterType: .path, isRequired: true),
                .init(name: "third", typeInformation: try TypeInformation(type: TestTypes.Car.self), parameterType: .content, isRequired: true)
            ],
            response: lhs.response,
            errors: lhs.errors
        )
        
        let endpointComparator = EndpointComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        endpointComparator.compare()
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? UpdateChange)
        XCTAssert(change.element == .endpoint("test", target: .queryParameter))
        XCTAssert(change.parameterTarget == .typeInformation)
        XCTAssert(change.targetID == .init("first"))
        XCTAssert(change.convertionWarning == nil)
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        if case let .element(codable) = change.to, let scriptID = change.convertFromTo, let script = node.scripts[scriptID] {
            XCTAssert(codable.typed(TypeInformation.self) == .scalar(.bool))
            XCTAssertNoThrow(try Bool.from("", script: script), "Invalid script to convert string to bool")
        } else {
            XCTFail("Change did not provide the required script to convert the updated parameter type")
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
            absolutePath: lhs.path.description,
            parameters: lhs.parameters,
            response: try TypeInformation(type: RHSResponse.self),
            errors: lhs.errors
        )
        
        let endpointComparator = EndpointComparator(lhs: lhs, rhs: rhs, changes: node, configuration: .default)
        endpointComparator.compare()
        XCTAssert(node.changes.count == 1)
        let change = try XCTUnwrap(node.changes.first as? UpdateChange)
        XCTAssert(change.element == .endpoint("test", target: .response))
        XCTAssert(change.convertionWarning == nil)
        XCTAssert(change.breaking)
        XCTAssert(change.solvable)
        if case let .element(codable) = change.to, let scriptID = change.convertToFrom, let script = node.scripts[scriptID] {
            XCTAssert(codable.typed(TypeInformation.self) == .reference(.init("EndpointComparatorTestsRHSResponse")))
            let id = UUID()
            let instance = XCTAssertNoThrowWithResult(try LHSResponse.from(RHSResponse(identifier: id, name: "someResponse"), script: script))
            XCTAssert(instance.id == id)
            XCTAssert(instance.name == "someResponse")
            XCTAssert(instance.age == 0)
        } else {
            XCTFail("Change did not provide the required script to convert the updated response type")
        }
    }
}
