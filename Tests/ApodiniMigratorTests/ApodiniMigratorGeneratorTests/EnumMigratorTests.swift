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
import PathKit

final class EnumMigratorTests: ApodiniMigratorXCTestCase {
    let enumeration: TypeInformation = .enum(
        name: .init(rawValue: "ProgLang"),
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
    
    private var addCaseChange: ModelChange {
        .update(
            id: enumeration.deltaIdentifier,
            updated: .case(case: .addition(
                id: "go",
                added: EnumCase("go"),
                breaking: false,
                solvable: true
            )),
            breaking: false,
            solvable: true
        )
    }
    
    var deleteCaseChange: ModelChange {
        .update(
            id: enumeration.deltaIdentifier,
            updated: .case(case: .removal(
                id: "other",
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }
    
    var renameCaseChange: ModelChange {
        .update(
            id: enumeration.deltaIdentifier,
            updated: .case(case: .idChange(
                from: "swift",
                to: "swiftLang",
                similarity: nil,
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }

    var updateRawValueChange: ModelChange {
        .update(
            id: enumeration.deltaIdentifier,
            updated: .case(case: .update(
                id: "swift",
                updated: .rawValueType(from: "swift", to: "swiftLang"),
                breaking: true,
                solvable: true
            )),
            breaking: true,
            solvable: true
        )
    }

    var deleteEnumChange: ModelChange {
        .removal(
            id: enumeration.deltaIdentifier,
            removed: nil,
            breaking: true,
            solvable: true
        )
    }

    var unsupportedRawValueChange: ModelChange {
        .update(
            id: enumeration.deltaIdentifier,
            updated: .rawValueType(from: .scalar(.string), to: .scalar(.int)),
            breaking: true,
            solvable: false
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
        let migrator = EnumMigrator(enumeration, changes: [addCaseChange])
        
        XCTMigratorAssertEqual(migrator, .enumAddedCase)
    }
    
    func testEnumDeletedCase() throws {
        let migrator = EnumMigrator(enumeration, changes: [deleteCaseChange])
        XCTMigratorAssertEqual(migrator, .enumDeletedCase)
    }
    
    func testEnumRenamedCase() throws {
        let migrator = EnumMigrator(enumeration, changes: [renameCaseChange])
        XCTMigratorAssertEqual(migrator, .enumRenamedCase)
    }
    
    func testEnumDeleted() throws {
        let migrator = EnumMigrator(enumeration, changes: [deleteEnumChange])
        XCTMigratorAssertEqual(migrator, .enumDeletedSelf)
    }
    
    func testEnumUnsupportedChange() throws {
        let migrator = EnumMigrator(enumeration, changes: [unsupportedRawValueChange])
        
        XCTMigratorAssertEqual(migrator, .enumUnsupportedChange)
    }
    
    func testEnumMultipleChanges() throws {
        let migrator = EnumMigrator(enumeration, changes: [addCaseChange, deleteCaseChange, renameCaseChange, updateRawValueChange])
        XCTMigratorAssertEqual(migrator, .enumMultipleChanges)
    }
}
