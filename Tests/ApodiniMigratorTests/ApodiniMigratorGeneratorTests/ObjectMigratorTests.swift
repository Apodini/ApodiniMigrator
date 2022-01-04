//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import RESTMigrator
@testable import ApodiniMigrator
@testable import ApodiniMigratorCompare

final class ObjectMigratorTests: ApodiniMigratorXCTestCase {
    private let user: TypeInformation = .object(
        name: .init(rawValue: "User"),
        properties: [
            .init(name: "id", type: .scalar(.uuid)),
            .init(name: "name", type: .scalar(.string)),
            .init(name: "isStudent", type: .scalar(.string)),
            .init(name: "age", type: .optional(wrappedValue: .scalar(.uint))),
            .init(name: "githubProfile", type: .scalar(.url)),
            .init(name: "friends", type: .repeated(element: .scalar(.uuid)))
        ]
    )
    
    private var addPropertyChange: ModelChange {
        .update(
            id: user.deltaIdentifier,
            updated: .property(property: .addition(
                id: "username",
                added: TypeProperty(name: "username", type: .scalar(.string)),
                defaultValue: 1,
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }
    
    private var deletePropertyChange: ModelChange {
        .update(
            id: user.deltaIdentifier,
            updated: .property(property: .removal(
                id: "friends",
                fallbackValue: 2,
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }
    
    private var renamedPropertyChange: ModelChange {
        .update(
            id: user.deltaIdentifier,
            updated: .property(property: .idChange(
                from: "githubProfile",
                to: "githubURL",
                similarity: 0,
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }
    
    private var propertyNecessityToRequiredChange: ModelChange {
        .update(
            id: user.deltaIdentifier,
            updated: .property(property: .update(
                id: "age",
                updated: .necessity(from: .optional, to: .required, necessityMigration: 3),
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }
    
    private var propertyNecessityToOptionalChange: ModelChange {
        .update(
            id: user.deltaIdentifier,
            updated: .property(property: .update(
                id: "name",
                updated: .necessity(from: .required, to: .optional, necessityMigration: 4),
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }
    
    private var propertyTypeChange: ModelChange {
        .update(
            id: user.deltaIdentifier,
            updated: .property(property: .update(
                id: "isStudent",
                updated: .type(
                    from: .scalar(.string),
                    to: .scalar(.bool),
                    forwardMigration: 1,
                    backwardMigration: 2,
                    conversionWarning: nil
                ),
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }

    private var objectRemovalChange: ModelChange {
        .removal(
            id: user.deltaIdentifier,
            fallbackValue: nil,
            breaking: true,
            solvable: true
        )
    }

    private var objectUnsupportedRootTypeChange: ModelChange {
        .update(
            id: user.deltaIdentifier,
            updated: .rootType(
                from: .object,
                to: .enum,
                newModel: .enum(
                    name: .init(rawValue: user.deltaIdentifier.rawValue),
                    rawValueType: .scalar(.string),
                    cases: [EnumCase("ok")]
                )
            ),
            breaking: true,
            solvable: false
        )
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
        let migrator = ObjectMigrator(user, changes: [objectRemovalChange])
        XCTMigratorAssertEqual(migrator, .objectDeletedChange)
    }
    
    func testObjectUnsupportedChange() throws {
        let migrator = ObjectMigrator(user, changes: [objectUnsupportedRootTypeChange])
        XCTMigratorAssertEqual(migrator, .objectUnsupportedChange)
    }
}
