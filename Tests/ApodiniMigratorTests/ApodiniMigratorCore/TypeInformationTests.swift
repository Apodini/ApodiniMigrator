//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import ApodiniMigratorCore
@testable import ApodiniMigratorClientSupport

final class TypeInformationTests: ApodiniMigratorXCTestCase {
    func testJSONCreation() throws {
        let json = XCTAssertNoThrowWithResult(try JSONStringBuilder.jsonString(TestTypes.Student.self))
        
        let instance = XCTAssertNoThrowWithResult(try TestTypes.Student.decode(from: json))
        XCTAssert(instance.grades.isEmpty)
        XCTAssert(instance.age == 0)
        XCTAssert(instance.name.isEmpty)
    }
}
