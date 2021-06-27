import XCTest
@testable import ApodiniMigratorGenerator
@testable import ApodiniMigratorCompare

final class MigrationGuideTests: ApodiniMigratorXCTestCase {
    let document = Path.desktop + "delta_document.json"
    let packagePath: Path = .desktop
    
    func testPackageGenerator() throws {
        let gen = try ApodiniMigratorGenerator(
            packageName: "ExampleACD",
            packagePath: packagePath.string,
            documentPath: document.string,
            migrationGuide: .empty
        )
        
        
        XCTAssertNoThrow(try gen.build())
    }
    
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
