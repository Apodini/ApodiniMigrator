import XCTest
@testable import ApodiniMigrator
@testable import ApodiniMigratorShared
@testable import ApodiniMigratorCompare

final class MigrationGuideTests: ApodiniMigratorXCTestCase {
    let document = Path.desktop + "delta_document.json"
    let packagePath: Path = .desktop
    
    func testPackageMigration() throws {
        guard packagePath.exists, !skipFileReadingTests else {
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
        try ProjectFilesUpdater.run()
    }
    
    func testEnumDelete() throws {
        struct User {
            let name: String
            let id: UUID
            let age: Int
        }
        
        let typeInfo = try TypeInformation(type: User.self)
        let objectMigrator = ObjectMigrator(typeInfo, changes: [DeleteChange(element: .object(typeInfo.deltaIdentifier, target: .`self`), deleted: .none, fallbackValue: .none, breaking: true, solvable: false, includeProviderSupport: false)])
        
        try objectMigrator.write(at: .desktop)
        
        let endpoint = Endpoint(handlerName: "TestHandler", deltaIdentifier: "sayHelloWorld", operation: .read, absolutePath: "/v1/hello", parameters: [], response: .scalar(.string), errors: [.init(code: 404, message: "Could not say hello")])
        
        let endpointsFile = EndpointFile(typeInformation: .scalar(.string), endpoints: [endpoint], changes: [DeleteChange(element: .endpoint(endpoint.deltaIdentifier, target: .`self`), deleted: .none, fallbackValue: .none, breaking: true, solvable: false, includeProviderSupport: false)])
        try endpointsFile.write(at: .desktop)
    }
    
    func testMigrationGuide() throws {
        guard Path.desktop.exists, !skipFileReadingTests else {
            return
        }
        
        let doc = Path.desktop + "delta_document.json"
        let doc2 = Path.desktop + "delta_document_updated.json"
        
        let migrationGuide = try MigrationGuide.from(doc, doc2)
        try (Path.desktop + "migration_guide.json").write(migrationGuide.json)

        let decoded = try MigrationGuide.decode(from: Path.desktop + "migration_guide.json")
        XCTAssert(decoded == migrationGuide)
    }
}
