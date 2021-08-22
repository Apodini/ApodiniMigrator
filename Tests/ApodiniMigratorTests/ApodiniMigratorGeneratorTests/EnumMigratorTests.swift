import XCTest
@testable import ApodiniMigrator
@testable import ApodiniMigratorCompare
import PathKit

final class EnumMigratorTests: ApodiniMigratorXCTestCase {
    let enumeration: TypeInformation = .enum(
        name: .init(name: "ProgLang"),
        rawValueType: .string,
        cases: [
            .case("swift"),
            .case("python"),
            .case("java"),
            .case("objectiveC"),
            .case("javaScript"),
            .case("ruby"),
            .case("other")
        ]
    )
    
    private var addCaseChange: AddChange {
        .init(
            element: .enum(enumeration.deltaIdentifier, target: .case),
            added: .element(EnumCase("go")),
            defaultValue: .none,
            breaking: false,
            solvable: true
        )
    }
    
    var deleteCaseChange: DeleteChange {
        .init(
            element: .enum(enumeration.deltaIdentifier, target: .case),
            deleted: .elementID(.init("other")),
            fallbackValue: .none,
            breaking: true,
            solvable: true
        )
    }
    
    var renameCaseChange: UpdateChange {
        .init(
            element: .enum(enumeration.deltaIdentifier, target: .caseRawValue),
            from: .element(EnumCase("swift")),
            to: .element(EnumCase("swiftLang")),
            breaking: true,
            solvable: true
        )
    }
    
    override class func setUp() {
        super.setUp()
        
        FileHeaderComment.testsDate = .testsDate
    }
    
    func testDefaultStringEnumFile() throws {
        let file = DefaultEnumFile(enumeration)
        XCTFileAssertEqual(file, .defaultStringEnum)
    }
    
    func testDefaultIntEnumFile() throws {
        let file = DefaultEnumFile(.enum(name: enumeration.typeName, rawValueType: .int, cases: enumeration.enumCases))
        XCTFileAssertEqual(file, .defaultIntEnum)
    }
    
    func testEnumAddedCase() throws {
        let migrator = EnumMigrator(enum: enumeration, changes: [addCaseChange])
        
        XCTFileAssertEqual(migrator, .enumAddedCase)
    }
    
    func testEnumDeletedCase() throws {
        let migrator = EnumMigrator(enum: enumeration, changes: [deleteCaseChange])
        XCTFileAssertEqual(migrator, .enumDeletedCase)
    }
    
    func testEnumRenamedCase() throws {
        
        let migrator = EnumMigrator(enum: enumeration, changes: [renameCaseChange])
        XCTFileAssertEqual(migrator, .enumRenamedCase)
    }
    
    func testEnumDeleted() throws {
        let deletedSelfChange = DeleteChange(
            element: .enum(enumeration.deltaIdentifier, target: .`self`),
            deleted: .elementID(enumeration.deltaIdentifier),
            fallbackValue: .none,
            breaking: true,
            solvable: true
        )
        
        let migrator = EnumMigrator(enum: enumeration, changes: [deletedSelfChange])
        XCTFileAssertEqual(migrator, .enumDeletedSelf)
    }
    
    func testEnumUnsupportedChange() throws {
        let unsupportedChange = UnsupportedChange(
            element: .enum(enumeration.deltaIdentifier, target: .`self`),
            description: "Unsupported change! Raw value type changed"
        )
        
        let migrator = EnumMigrator(enum: enumeration, changes: [unsupportedChange])
        
        XCTFileAssertEqual(migrator, .enumUnsupportedChange)
    }
    
    func testEnumMultipleChanges() throws {
        let migrator = EnumMigrator(enum: enumeration, changes: [addCaseChange, deleteCaseChange, renameCaseChange])
        XCTFileAssertEqual(migrator, .enumMultipleChanges)
    }
}
