//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
import PathKit
@testable import ApodiniMigratorCompare
@testable import ApodiniMigrator

class ApodiniMigratorXCTestCase: XCTestCase {
    var node = ChangeContextNode()
    
    let testDirectory = "./migrator"
    var testDirectoryPath: Path {
        testDirectory.asPath
    }
    
    private func testTestDirectoryCreated() throws {
        XCTAssert(testDirectoryPath.exists)
        XCTAssert(try testDirectoryPath.children().isEmpty)
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        if !testDirectoryPath.exists {
            try testDirectoryPath.mkpath()
        }
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        node = ChangeContextNode()
        try testDirectoryPath.delete()
    }
    
    func XCTAssertNoThrowWithResult<T>(_ expression: @autoclosure () throws -> T) -> T {
        XCTAssertNoThrow(try expression())
        do {
            return try expression()
        } catch {
            XCTFail(error.localizedDescription)
        }
        preconditionFailure("Expression threw an error")
    }
    
    func XCTAssertThrows<T>(_ expression: @autoclosure () throws -> T) {
        let expectation = XCTestExpectation(description: "Expression did throw")
        do {
            _ = try expression()
            XCTFail("Expression did not throw")
        } catch {
            expectation.fulfill()
        }
    }
    
    func firstNonEqualLine(lhs: String, _ rhs: String, function: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        for (lhsLine, rhsLine) in zip(lhs.lines(), rhs.lines()) where lhsLine != rhsLine {
            print("Lhs line: \(lhsLine)")
            print("Rhs line: \(rhsLine)")
            fatalError("Found non-equal line in \(function)", file: file, line: line)
        }
    }
    
    func XCTMigratorAssertEqual(_ rendarable: Renderable, _ resource: OutputFiles) {
        XCTAssertEqual(rendarable.indentationFormatted(), resource.content().indentationFormatted())
    }
    
    func canImportJavaScriptCore() -> Bool {
        #if canImport(JavaScriptCore)
        return true
        #else
        print("Test skipped because JavaScriptCore is not available in this platform")
        return false
        #endif
    }
}
