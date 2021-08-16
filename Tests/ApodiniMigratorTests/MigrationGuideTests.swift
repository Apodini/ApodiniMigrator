import XCTest
@testable import ApodiniMigrator
@testable import ApodiniMigratorShared
@testable import ApodiniMigratorCompare

final class MigrationGuideTests: ApodiniMigratorXCTestCase {
    let document = Path.desktop + "api_qonectiq1.0.0.json"
    let packagePath: Path = .desktop
    
    func testPackageMigration() throws {
        guard isEldisMacbook(), !skipFileReadingTests else {
            return
        }
        
        let mig = try MigrationGuide.decode(from: .desktop + "migration_guide.json")
        let migrator = try Migrator(
            packageName: "TestMigPackage",
            packagePath: packagePath.string,
            documentPath: document.string,
            migrationGuide: mig
        )
        
        try migrator.migrate()
    }
    
    func testProjectFilesUpdater() throws {
        guard isEldisMacbook() else {
            return
        }
        try ProjectFilesUpdater.run()
    }
    
    func testEnumDelete() throws {
        guard isEldisMacbook() else {
            return
        }
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
        guard isEldisMacbook(), !skipFileReadingTests else {
            return
        }
        
        let doc = Path.desktop + "api_qonectiq1.0.0.json"
        let doc2 = Path.desktop + "api_qonectiq2.0.0.json"
        
        let migrationGuide = try MigrationGuide.from(doc, doc2)
        try (Path.desktop + "migration_guide.json").write(migrationGuide.json)

        let decoded = try MigrationGuide.decode(from: Path.desktop + "migration_guide.json")
        XCTAssert(decoded == migrationGuide)
    }
}
