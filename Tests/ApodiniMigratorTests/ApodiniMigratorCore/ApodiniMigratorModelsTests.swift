import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorClientSupport

final class ApodiniMigratorModelsTests: ApodiniMigratorXCTestCase {
    
    func testFluentProperties() throws {
        try FluentPropertyType.allCases.forEach { property in
            let json = property.json
            let instance = XCTAssertNoThrowWithResult(try FluentPropertyType.decode(from: json))
            XCTAssertEqual(property.description, property.debugDescription)
            XCTAssert(instance == property)
        }
        
        try XCTAssertThrows(try FluentPropertyType.decode(from: "@FluentID".json))
    }
    
    func testDSLEndpointIdentifier() {
        var errors: [ErrorCode] = []
        errors.addError(404, message: "Not found")
        let noIDEndpoint = Endpoint(
            handlerName: "SomeHandler",
            deltaIdentifier: "0.1.0.0.1",
            operation: .create,
            absolutePath: "/v1/test",
            parameters: [],
            response: .scalar(.bool),
            errors: errors
        )
        
        let withIDEndpoint = Endpoint(
            handlerName: "SomeHandler",
            deltaIdentifier: "getSomeHandler",
            operation: .read,
            absolutePath: "/v1/test",
            parameters: [],
            response: .scalar(.bool),
            errors: errors
        )
        
        XCTAssert(noIDEndpoint.deltaIdentifier == .init(noIDEndpoint.handlerName.lowerFirst))
        XCTAssert(withIDEndpoint.deltaIdentifier == "getSomeHandler")
    }
}
