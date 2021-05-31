//
//  ExampleACDTests.swift.swift
//
//  Created by ApodiniMigrator on 31.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import XCTest
@testable import ExampleACD

final class ExampleACDTests: XCTestCase {
    // MARK: - Encoder - Decoder
    private static let encoder = NetworkingService.encoder
    private static let decoder = NetworkingService.decoder
    
    func testContact() throws {
        let jsonString = "{\"birthday\" : 644186972.83688903, \"id\" : \"B00BEB9D-8AFD-43BA-9C2E-4A7BB401AB7F\", \"name\" : \"\"}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(Contact.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testContactMediator() throws {
        let jsonString = "{\"birthday\" : 644186972.83745205, \"name\" : \"\"}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(ContactMediator.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testResidence() throws {
        let jsonString = "{\"address\" : \"\", \"country\" : \"\", \"id\" : \"7C78DCC1-1BB5-48B4-9152-360E706A5055\", \"postalCode\" : \"\"}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(Residence.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testStatus() throws {
        let jsonString = "\"ok\""
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(Status.self, from: data))
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
