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
        let jsonString = "{\"birthday\" : 644181157.12905395, \"createdAt\" : 644181157.12934804, \"id\" : \"B72952F5-B4A5-4D7A-AC94-0A45DFA09F0B\", \"name\" : \"\"}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(Contact.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testContactMediator() throws {
        let jsonString = "{\"birthday\" : 644181157.12955296, \"name\" : \"\"}"
        let data = jsonString.data(using: .utf8) ?? Data()
        
        let instance = XCTAssertNoThrowWithResult(try Self.decoder.decode(ContactMediator.self, from: data))
        XCTAssertNoThrow(try Self.encoder.encode(instance))
    }
    
    func testResidence() throws {
        let jsonString = "{\"address\" : \"\", \"country\" : \"\", \"createdAt\" : 644181157.12970102, \"id\" : \"6822BFE6-CA5E-4F0F-BE02-CDF26BE1ABE5\", \"postalCode\" : \"\"}"
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
