import XCTest
@testable import ApodiniMigrator
@testable import ApodiniMigratorCompare
import PathKit

final class AuxiliaryFileGeneratorTests: ApodiniMigratorXCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        FileHeaderComment.testsDate = .testsDate
    }
    
    func testTestFile() throws {
        let object: TypeInformation = .object(
            name: .init(name: "TestObject"),
            properties: [
                .init(name: "prop1", type: .scalar(.bool)),
                .init(name: "prop2", type: .scalar(.uint)),
                .init(name: "prop3", type: .dictionary(key: .int, value: .scalar(.string))),
                .init(name: "prop4", type: .scalar(.uint)),
                .init(name: "prop5", type: .optional(wrappedValue: .scalar(.string))),
                .init(name: "prop6", type: .scalar(.string))
            ]
        )
        
        let enumeration: TypeInformation = .enum(
            name: .init(name: "TestEnumeration"),
            rawValueType: .string,
            cases: [
                .case("first"),
                .case("second")
            ]
        )
        
        let testFile = TestFileTemplate([object, enumeration], fileName: "TestFile", packageName: "ApodiniMigrator")
        
        XCTFileAssertEqual(testFile, .modelsTestFile)
    }
    
    func testAPIFile() throws {
        let endpoint = Endpoint(
            handlerName: "TestHandler",
            deltaIdentifier: "sayHelloWorld",
            operation: .read,
            absolutePath: "/v1/hello",
            parameters: [],
            response: .scalar(.string),
            errors: [.init(code: 404, message: "Could not say hello")]
        )
        let file = APIFile([.init(endpoint: endpoint, unavailable: false, parameters: [], path: endpoint.path)])
        
        XCTFileAssertEqual(file, .aPIFile)
    }
}
