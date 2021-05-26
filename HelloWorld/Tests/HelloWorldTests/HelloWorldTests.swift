//
//  HelloWorldTests.swift.swift
//
//  Created by ApodiniMigrator on 26.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import XCTest
@testable import HelloWorld

final class HelloWorldTests: XCTestCase {
    // MARK: - Encoder - Decoder
    private static let encoder = NetworkingService.encoder
    private static let decoder = NetworkingService.decoder
    
    func testPost() throws {
        let jsonString = "{\"id\" : \"B809756B-7CAF-47A4-85B5-BDD471170278\", \"title\" : \"\"}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(Post.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testUser() throws {
        let jsonString = "{\"id\" : 0, \"writtenId\" : \"9FE22762-2721-4D17-A311-AB11BDD48C8B\"}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(User.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func XCTAssertNoThrowWithResult<T>(_ expression: @autoclosure () throws -> T) -> T {
        XCTAssertNoThrow(try expression())
        do {
            return try expression()
        } catch {
            preconditionFailure("Expression threw an error: \(error.localizedDescription)")
        }
    }
}
