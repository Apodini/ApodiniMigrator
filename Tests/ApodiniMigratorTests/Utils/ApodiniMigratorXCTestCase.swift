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
@testable import RESTMigrator
@testable import ApodiniMigrator

class ApodiniMigratorXCTestCase: XCTestCase {
    var node = ChangeContextNode() // TODO remove
    var comparisonContext = ChangeComparisonContext()
    
    let testDirectory = "./\(UUID().uuidString)"
    var testDirectoryPath: Path {
        Path(testDirectory)
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
        
        node = ChangeContextNode() // TODO remove
        comparisonContext = ChangeComparisonContext()
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
            try _ = expression()
            XCTFail("Expression did not throw")
        } catch {
            expectation.fulfill()
        }
    }
    
    func firstNonEqualLine(lhs: String, _ rhs: String, function: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        let lhsLines = lhs.components(separatedBy: "\n")
        let rhsLines = rhs.components(separatedBy: "\n")

        for (lhsLine, rhsLine) in zip(lhsLines, rhsLines) where lhsLine != rhsLine {
            print("Lhs line: \(lhsLine)")
            print("Rhs line: \(rhsLine)")
            fatalError("Found non-equal line in \(function)", file: file, line: line)
        }
    }

    @inlinable
    func XCTMigratorAssertEqual(
        _ rendarable: GeneratedFile,
        _ resource: OutputFiles,
        with context: MigrationContext = MigrationContext(packageName: "ApodiniMigrator"),
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            rendarable.formattedFile(with: context),
            resource.content(), // TODO .indentatioNFormatted of content is missing!
            message(),
            file: file,
            line: line
        )
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

extension MigrationContext {
    init(packageName: String) {
        self.init(
            bundle: .module,
            logger: .init(label: "org.apodini.test")
        )

        placeholderValues[GlobalPlaceholder.$packageName] = packageName
    }
}
