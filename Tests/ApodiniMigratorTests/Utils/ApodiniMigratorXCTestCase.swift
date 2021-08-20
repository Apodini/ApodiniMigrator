//
//  File.swift
//  
//
//  Created by Eldi Cano on 03.06.21.
//

import XCTest
import PathKit
@testable import ApodiniMigratorCompare

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
    
    func isLinux() -> Bool {
        #if os(Linux)
        return true
        #else
        return false
        #endif
    }
}
