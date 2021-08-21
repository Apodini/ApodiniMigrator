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
        
        XCTAssertThrows(try FluentPropertyType.decode(from: "@FluentID".json))
        
        let childredMangledName = MangledName("ChildrenProperty")
        if case let .fluentPropertyType(type) = childredMangledName {
            XCTAssert(type == .childrenProperty)
            XCTAssert(type.isGetOnly)
        } else {
            XCTFail("Mangled name did not correspond to a fluent property")
        }
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
    
    func testWrappedContentParameters() throws {
        let param1 = Parameter(name: "first", typeInformation: .scalar(.string), parameterType: .content, isRequired: true)
        let param2 = Parameter(name: "second", typeInformation: .scalar(.int), parameterType: .content, isRequired: false)
        
        let endpoint = Endpoint(
            handlerName: "someHandler",
            deltaIdentifier: "id",
            operation: .create,
            absolutePath: "/v1/test",
            parameters: [param1, param2],
            response: .scalar(.bool),
            errors: []
        )
        
        XCTAssert(endpoint.parameters.count == 1)
        let contentParameter = try XCTUnwrap(endpoint.parameters.first)
        XCTAssert(contentParameter.isWrapped)
        XCTAssert(contentParameter.typeInformation.isObject)
        XCTAssert(contentParameter.necessity == .required)
        XCTAssert(contentParameter.name == "\(Parameter.wrappedContentParameter)")
    }
    
    func testEndpointPath() throws {
        let pathString = "v1/user".json
        XCTAssertThrows(try EndpointPath.decode(from: pathString))
        
        let somePath = "/api/{id}/test".json
        XCTAssertThrows(try Endpoint.decode(from: somePath))
        
        let string = "/v1/{some}/users/{id}"
        let string1 = "/v1/{param}/users/{param}"
        let string2 = "/v2/{param}/users/{param}" // still considered equal, change is delegated to networking due to version change
  
        XCTAssert(EndpointPath(string) != EndpointPath(string1))
        XCTAssert(EndpointPath(string1) == EndpointPath(string2))
    }
    
    func testVersion() throws {
        let version = Version()
        XCTAssertEqual(version, .default)
        
        let versionFromString = try Version.decode(from: version.string.json)
        XCTAssertEqual(version, versionFromString)
        
        XCTAssertThrows(try Version.decode(from: "v123".json))
    }
    
    func testRuntime() throws {
        typealias User = TestTypes.User
        let info = try info(of: User.self)
        
        let name = try RuntimeProperty(XCTAssertNoThrowWithResult(try info.property(named: "name")))
        XCTAssert(name.ownerType == User.self)
        XCTAssert(name.genericTypes.count == 1)
        XCTAssert(!name.isIDProperty)
        XCTAssert(!name.isFluentProperty)
        
        XCTAssert(info.cardinality == .exactlyOne(User.self))
        
        XCTAssert(type(User.self, isAnyOf: .struct))
        XCTAssert(!type(type(of: ()), isAnyOf: .struct, .enum))
        
        let url = try XCTUnwrap(try createInstance(of: URL.self) as? URL)
        XCTAssert(url == .default)
        
        enum TestError: Error {
            case test
            case opaque
        }
        
        XCTAssert(!knownRuntimeError(TestError.test))
        
        XCTAssertThrows(try instance(User.self)) // can't create an enum instance
        XCTAssertNoThrow(try instance(TestTypes.Shop.self))
    }
    
    func testDocument() throws {
        var document = Document()
        document.add(
            endpoint: .init(
                handlerName: "someHandler",
                deltaIdentifier: "endpoint",
                operation: .create,
                absolutePath: "/test1/test",
                parameters: [],
                response: .scalar(.bool),
                errors: []
            )
        )
        document.setServerPath("http://127.0.0.1:8080")
        document.setVersion(Version(prefix: "test", major: 1, minor: 2, patch: 3))
        
        document.setCoderConfigurations(.default, .default)
        XCTAssert(document.fileName == "api_test1.2.3")
        XCTAssert(!document.endpoints.isEmpty)
        XCTAssertEqual(document.metaData.versionedServerPath, "http://127.0.0.1:8080/test1")
        XCTAssert(!document.json.isEmpty)
        XCTAssert(!document.yaml.isEmpty)
    }
    
    func testNull() throws {
        let null = Null()
        let data = XCTAssertNoThrowWithResult(try JSONEncoder().encode(null))
        XCTAssertNoThrow(try JSONDecoder().decode(Null.self, from: data))
        XCTAssertThrows(try JSONDecoder().decode(Null.self, from: .init()))
    }
}
