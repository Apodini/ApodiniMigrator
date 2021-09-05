//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import ApodiniMigrator
@testable import ApodiniMigratorCompare
import PathKit

final class EnumMigratorTests: ApodiniMigratorXCTestCase {
    let enumeration: TypeInformation = .enum(
        name: .init(name: "ProgLang"),
        rawValueType: .scalar(.string),
        cases: [
            .init("swift"),
            .init("python"),
            .init("java"),
            .init("objectiveC"),
            .init("javaScript"),
            .init("ruby"),
            .init("other")
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
            deleted: .elementID("other"),
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
        XCTMigratorAssertEqual(file, .defaultStringEnum)
    }
    
    func testDefaultIntEnumFile() throws {
        let file = DefaultEnumFile(.enum(name: enumeration.typeName, rawValueType: .scalar(.int), cases: enumeration.enumCases))
        XCTMigratorAssertEqual(file, .defaultIntEnum)
    }
    
    func testEnumAddedCase() throws {
        let migrator = EnumMigrator(enum: enumeration, changes: [addCaseChange])
        
        XCTMigratorAssertEqual(migrator, .enumAddedCase)
    }
    
    func testEnumDeletedCase() throws {
        let migrator = EnumMigrator(enum: enumeration, changes: [deleteCaseChange])
        XCTMigratorAssertEqual(migrator, .enumDeletedCase)
    }
    
    func testEnumRenamedCase() throws {
        
        let migrator = EnumMigrator(enum: enumeration, changes: [renameCaseChange])
        XCTMigratorAssertEqual(migrator, .enumRenamedCase)
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
        XCTMigratorAssertEqual(migrator, .enumDeletedSelf)
    }
    
    func testEnumUnsupportedChange() throws {
        let unsupportedChange = UnsupportedChange(
            element: .enum(enumeration.deltaIdentifier, target: .`self`),
            description: "Unsupported change! Raw value type changed"
        )
        
        let migrator = EnumMigrator(enum: enumeration, changes: [unsupportedChange])
        
        XCTMigratorAssertEqual(migrator, .enumUnsupportedChange)
    }
    
    func testEnumMultipleChanges() throws {
        let migrator = EnumMigrator(enum: enumeration, changes: [addCaseChange, deleteCaseChange, renameCaseChange])
        XCTMigratorAssertEqual(migrator, .enumMultipleChanges)
    }
}
