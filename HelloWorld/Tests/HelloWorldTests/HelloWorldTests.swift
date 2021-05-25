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
    
    func testPost() throws {
        let jsonString = "{\"id\" : \"A8984B04-AA33-4C69-8D2F-91FEEDFFB70E\", \"title\" : \"\"}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(Post.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testUserResponse() throws {
        let jsonString = "{\"_links\" : { \"\" : \"\" }, \"data\" : {\"id\" : 0, \"writtenId\" : \"383A67AE-2C71-4EDD-9990-E11F60DBB771\"}}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(UserResponse.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testPostResponse() throws {
        let jsonString = "{\"_links\" : { \"\" : \"\" }, \"data\" : {\"id\" : \"E4A4164B-5C61-4908-9EFD-4DEF3AB83527\", \"title\" : \"\"}}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(PostResponse.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testUser() throws {
        let jsonString = "{\"id\" : 0, \"writtenId\" : \"A697ECBF-D1C0-4FF3-B71C-96850F69FE56\"}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(User.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testStringResponse() throws {
        let jsonString = "{\"_links\" : { \"\" : \"\" }, \"data\" : \"\"}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(StringResponse.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testIntResponse() throws {
        let jsonString = "{\"_links\" : { \"\" : \"\" }, \"data\" : 0}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(IntResponse.self, from: data))
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
