//
//  File.swift
//  
//
//  Created by Eldi Cano on 03.06.21.
//

import XCTest

class ApodiniMigratorXCTestCase: XCTestCase {
    func XCTAssertNoThrowWithResult<T>(_ expression: @autoclosure () throws -> T) -> T {
        XCTAssertNoThrow(try expression())
        
        do {
            return try expression()
        } catch {
            XCTFail(error.localizedDescription)
        }
        preconditionFailure("Expression threw an error")
    }
}
