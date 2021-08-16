import XCTest
@testable import ApodiniMigrator
@testable import ApodiniMigratorShared
@testable import ApodiniMigratorCompare

enum Docs: String, Resource {
    case v1 = "api_qonectiq1.0.0"
    case mig = "migration_guide"
    case v2 = "api_qonectiq2.0.0"
    
    var fileExtension: FileExtension { .json }
    var name: String { rawValue }
    
    var bundle: Bundle { .module }
}

final class MigrationGuideTests: ApodiniMigratorXCTestCase {
    
    func testPackageMigration() throws {
        let mig = try MigrationGuide.decode(from: try Docs.mig.data())
        let migrator = try Migrator(
            packageName: "TestMigPackage",
            packagePath: Self.testDirectory,
            documentPath: Docs.v1.path.string,
            migrationGuide: mig
        )
        
        try migrator.migrate()
    }
    
    func testProjectFilesUpdater() throws {
        try ProjectFilesUpdater.run()
    }
    
    func testEnumDelete() throws {
        struct User {
            let name: String
            let id: UUID
            let age: Int
        }
        // TODO review
        let typeInfo = try TypeInformation(type: User.self)
        _ = ObjectMigrator(typeInfo, changes: [DeleteChange(element: .object(typeInfo.deltaIdentifier, target: .`self`), deleted: .none, fallbackValue: .none, breaking: true, solvable: false, includeProviderSupport: false)])
        
        let endpoint = Endpoint(handlerName: "TestHandler", deltaIdentifier: "sayHelloWorld", operation: .read, absolutePath: "/v1/hello", parameters: [], response: .scalar(.string), errors: [.init(code: 404, message: "Could not say hello")])
        
        _ = EndpointFile(typeInformation: .scalar(.string), endpoints: [endpoint], changes: [DeleteChange(element: .endpoint(endpoint.deltaIdentifier, target: .`self`), deleted: .none, fallbackValue: .none, breaking: true, solvable: false, includeProviderSupport: false)])
    }
    
    func testMigrationGuide() throws {
        let doc1 = try Docs.v1.instance() as Document
        let doc2 = try Docs.v2.instance() as Document
        
        let migrationGuide = MigrationGuide(for: doc1, rhs: doc2)
        try (Self.testDirectoryPath + "migration_guide.json").write(migrationGuide.json)

        let decoded = try MigrationGuide.decode(from: Self.testDirectoryPath + "migration_guide.json")
        XCTAssert(decoded == migrationGuide)
    }
}
