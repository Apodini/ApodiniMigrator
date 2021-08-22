//
//  File.swift
//  
//
//  Created by Eldi Cano on 03.06.21.
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
    
    func XCTFileAssertEqual(_ rendarable: Renderable, _ resource: OutputFiles) {
        XCTMigratorAssertEqual(rendarable.render(), resource)
    }
    
    func XCTMigratorAssertEqual(_ expression: String, _ resource: OutputFiles, overrideResource: Bool = false) {
        do {
            let instanceContent = resource.content()
//            
//            if expression.lines().count != instanceContent.lines().count {
//                fatalError("Different lines: \(expression.lines().count) and \(instanceContent.lines().count)")
//            }
            
            if expression != instanceContent, overrideResource {
                try resource.write(content: expression)
            }
            
            XCTAssertEqual(expression.indentationFormatted(), instanceContent.indentationFormatted())
        } catch {
            XCTFail(error.localizedDescription)
        }
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
