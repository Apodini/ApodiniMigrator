import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorClientSupport

final class TypeInformationTests: ApodiniMigratorXCTestCase {
    func testJSONCreation() throws {
        let json = XCTAssertNoThrowWithResult(try JSONStringBuilder.jsonString(TestTypes.Student.self))
        
        let instance = XCTAssertNoThrowWithResult(try TestTypes.Student.decode(from: json))
        XCTAssert(instance.grades.isEmpty)
        XCTAssert(instance.age == 0)
        XCTAssert(instance.name == "")
    }
}
