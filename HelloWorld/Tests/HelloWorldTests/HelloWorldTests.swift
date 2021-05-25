//
//  HelloWorldTests.swift.swift
//
//  Created by ApodiniMigrator on 25.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import XCTest
@testable import HelloWorld

final class HelloWorldTests: XCTestCase {
    // MARK: - Encoder - Decoder
    private static let encoder = NetworkingService.encoder
    private static let decoder = NetworkingService.decoder
    
    func testIntResponse() throws {
        let jsonString = "{\"_links\" : { \"\" : \"\" }, \"data\" : 0}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(IntResponse.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testPost() throws {
        let jsonString = "{\"id\" : \"6F86E0BA-F5C4-489A-B0DA-1B2E36820C46\", \"title\" : \"\"}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(Post.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testPostResponse() throws {
        let jsonString = "{\"_links\" : { \"\" : \"\" }, \"data\" : {\"id\" : \"0EDBECF9-9F1D-4F6E-832C-9D14A4E36013\", \"title\" : \"\"}}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(PostResponse.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testStringResponse() throws {
        let jsonString = "{\"_links\" : { \"\" : \"\" }, \"data\" : \"\"}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(StringResponse.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testUser() throws {
        let jsonString = "{\"id\" : 0, \"writtenId\" : \"08253FAD-7E31-4E03-AED7-0C59905614C8\"}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(User.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testUserResponse() throws {
        let jsonString = "{\"_links\" : { \"\" : \"\" }, \"data\" : {\"id\" : 0, \"writtenId\" : \"5561BD4B-4BE7-475A-ABF3-19DA6ED88229\"}}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(UserResponse.self, from: data))
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
