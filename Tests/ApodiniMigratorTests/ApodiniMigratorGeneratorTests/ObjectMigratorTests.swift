import XCTest
@testable import ApodiniMigrator
@testable import ApodiniMigratorCompare
import PathKit

final class ObjectMigratorTests: ApodiniMigratorXCTestCase {
    private let user: TypeInformation = .object(
        name: .init(name: "User"),
        properties: [
            .init(name: "id", type: .scalar(.uuid)),
            .init(name: "name", type: .scalar(.string)),
            .init(name: "isStudent", type: .scalar(.string)),
            .init(name: "age", type: .optional(wrappedValue: .scalar(.uint))),
            .init(name: "githubProfile", type: .scalar(.url)),
            .init(name: "friends", type: .repeated(element: .scalar(.uuid)))
        ]
    )
    
    private var addPropertyChange: AddChange {
        .init(
            element: .object(user.deltaIdentifier, target: .property),
            added: .element(TypeProperty(name: "username", type: .scalar(.string))),
            defaultValue: .json(1),
            breaking: true,
            solvable: true
        )
    }
    
    private var deletePropertyChange: DeleteChange {
        .init(
            element: .object(user.deltaIdentifier, target: .property),
            deleted: .elementID("friends"),
            fallbackValue: .json(2),
            breaking: true,
            solvable: true
        )
    }
    
    private var renamedPropertyChange: UpdateChange {
        .init(
            element: .object(user.deltaIdentifier, target: .property),
            from: "githubProfile",
            to: "githubURL",
            similarity: 0,
            breaking: true,
            solvable: true
        )
    }
    
    private var propertyNecessityToRequiredChange: UpdateChange {
        UpdateChange(
            element: .object(user.deltaIdentifier, target: .necessity),
            from: .element(Necessity.optional),
            to: .element(Necessity.required),
            necessityValue: .json(3),
            targetID: "age",
            breaking: true,
            solvable: true
        )
    }
    
    private var propertyNecessityToOptionalChange: UpdateChange {
        UpdateChange(
            element: .object(user.deltaIdentifier, target: .necessity),
            from: .element(Necessity.required),
            to: .element(Necessity.optional),
            necessityValue: .json(4),
            targetID: "name",
            breaking: true,
            solvable: true
        )
    }
    
    private var propertyTypeChange: UpdateChange {
        .init(
            element: .object(user.deltaIdentifier, target: .property),
            from: .element(TypeInformation.scalar(.string)),
            to: .element(TypeInformation.scalar(.bool)),
            targetID: "isStudent",
            convertFromTo: 1,
            convertToFrom: 2,
            convertionWarning: nil,
            breaking: true,
            solvable: true)
    }
    
    override class func setUp() {
        super.setUp()
        
        FileHeaderComment.testsDate = .testsDate
    }
    
    func testDefaultObjectFile() {
        XCTMigratorAssertEqual(DefaultObjectFile(user), .defaultObjectFile)
    }
    
    func testAddedObjectProperty() throws {
        let migrator = ObjectMigrator(user, changes: [addPropertyChange])
        XCTMigratorAssertEqual(migrator, .objectAddedProperty)
    }
    
    func testDeletedObjectProperty() throws {
        let migrator = ObjectMigrator(user, changes: [deletePropertyChange])
        XCTMigratorAssertEqual(migrator, .objectDeletedProperty)
    }
    
    func testRenamedObjectProperty() throws {
        let migrator = ObjectMigrator(user, changes: [renamedPropertyChange])
        XCTMigratorAssertEqual(migrator, .objectRenamedProperty)
    }
    
    func testPropertyNecessityToRequiredChange() throws {
        let migrator = ObjectMigrator(user, changes: [propertyNecessityToRequiredChange])
        XCTMigratorAssertEqual(migrator, .objectPropertyNecessityToRequiredChange)
    }
    
    func testPropertyNecessityToOptionalChange() throws {
        let migrator = ObjectMigrator(user, changes: [propertyNecessityToOptionalChange])
        XCTMigratorAssertEqual(migrator, .objectPropertyNecessityToOptionalChange)
    }
    
    func testPropertyTypeChange() throws {
        let migrator = ObjectMigrator(user, changes: [propertyTypeChange])
        XCTMigratorAssertEqual(migrator, .objectPropertyTypeChange)
    }
    
    func testMultipleObjectChanges() throws {
        let migrator = ObjectMigrator(
            user,
            changes: [
                addPropertyChange,
                deletePropertyChange,
                renamedPropertyChange,
                propertyTypeChange,
                propertyNecessityToRequiredChange,
                propertyNecessityToOptionalChange
            ]
        )
        
        XCTMigratorAssertEqual(migrator, .objectMultipleChange)
    }
    
    func testObjectDeleted() throws {
        let deletedSelfChange = DeleteChange(
            element: .object(user.deltaIdentifier, target: .`self`),
            deleted: .elementID(user.deltaIdentifier),
            fallbackValue: .none,
            breaking: true,
            solvable: true
        )
        
        let migrator = ObjectMigrator(user, changes: [deletedSelfChange])
        XCTMigratorAssertEqual(migrator, .objectDeletedChange)
    }
    
    func testObjectUnsupportedChange() throws {
        let unsupportedChange = UnsupportedChange(
            element: .object(user.deltaIdentifier, target: .`self`),
            description: "Unsupported change! Type changed to enum"
        )
        
        let migrator = ObjectMigrator(user, changes: [unsupportedChange])
        XCTMigratorAssertEqual(migrator, .objectUnsupportedChange)
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
            rawValueType: .scalar(.string),
            cases: [
                .init("first"),
                .init("second")
            ]
        )
        
        let testFile = TestFileTemplate([object, enumeration], fileName: "TestFile", packageName: "ApodiniMigrator")
        
        XCTMigratorAssertEqual(testFile, .modelsTestFile)
    }
}
