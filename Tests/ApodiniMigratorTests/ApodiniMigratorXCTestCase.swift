//
//  File.swift
//  
//
//  Created by Eldi Cano on 03.06.21.
//

import XCTest
import PathKit

class ApodiniMigratorXCTestCase: XCTestCase {
    static let testDirectory = "./migrator"
    static var testDirectoryPath: Path {
        testDirectory.asPath
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        if !Self.testDirectoryPath.exists {
            try Self.testDirectoryPath.mkpath()
        }
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        try Self.testDirectoryPath.delete()
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
    
    func isLinux() -> Bool {
        #if os(Linux)
        return true
        #else
        return false
        #endif
    }
}
