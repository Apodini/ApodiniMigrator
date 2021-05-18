import XCTest
@testable import ApodiniMigrator
@testable import ApodiniMigratorGenerator

final class PackageGeneratorTests: XCTestCase {
    func testPackageGenerator() throws {
        let packageName = "HelloWorld"
        let desktop = Path.desktop.string
        let docPath = Path.desktop + "document.json"
        let generator = try ApodiniMigratorGenerator(packageName: packageName, packagePath: desktop, documentPath: docPath.string)
        try generator.build()
    }
}
