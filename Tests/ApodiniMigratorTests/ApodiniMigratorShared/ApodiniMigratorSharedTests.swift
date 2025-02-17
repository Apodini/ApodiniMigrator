//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import XCTest
@testable import ApodiniMigratorClientSupport
@testable import ApodiniMigratorExporterSupport

final class ApodiniMigratorSharedTests: ApodiniMigratorXCTestCase {
    func testCodingStrategies() {
        for strategy in [JSONEncoder.DataEncodingStrategy.deferredToData, .base64] {
            let mapped = DataEncodingStrategy(from: strategy)
            XCTAssertEqual(strategy, mapped.toJSONEncoderStrategy)
        }

        for strategy in [JSONEncoder.DateEncodingStrategy.deferredToDate, .iso8601, .millisecondsSince1970, .secondsSince1970] {
            let mapped = DateEncodingStrategy(from: strategy)
            XCTAssertEqual(strategy, mapped.toJSONEncoderStrategy)
        }

        for strategy in [JSONDecoder.DataDecodingStrategy.deferredToData, .base64] {
            let mapped = DataDecodingStrategy(from: strategy)
            XCTAssertEqual(strategy, mapped.toJSONDecoderStrategy)
        }

        for strategy in [JSONDecoder.DateDecodingStrategy.deferredToDate, .iso8601, .millisecondsSince1970, .secondsSince1970] {
            let mapped = DateDecodingStrategy(from: strategy)
            XCTAssertEqual(strategy, mapped.toJSONDecoderStrategy)
        }
    }

    func testDecodingStrategy() {
        let decoder = JSONDecoder()
        
        decoder.configured(with: .init(dateDecodingStrategy: .deferredToDate, dataDecodingStrategy: .deferredToData))
        XCTAssertEqual(decoder.dateDecodingStrategy, .deferredToDate)
        XCTAssertEqual(decoder.dataDecodingStrategy, .deferredToData)
        
        decoder.configured(with: .init(dateDecodingStrategy: .secondsSince1970, dataDecodingStrategy: .deferredToData))
        XCTAssertEqual(decoder.dateDecodingStrategy, .secondsSince1970)
        XCTAssertEqual(decoder.dataDecodingStrategy, .deferredToData)
        
        decoder.configured(with: .init(dateDecodingStrategy: .millisecondsSince1970, dataDecodingStrategy: .deferredToData))
        XCTAssertEqual(decoder.dateDecodingStrategy, .millisecondsSince1970)
        XCTAssertEqual(decoder.dataDecodingStrategy, .deferredToData)
        
        decoder.configured(with: .init(dateDecodingStrategy: .iso8601, dataDecodingStrategy: .deferredToData))
        XCTAssertEqual(decoder.dateDecodingStrategy, .iso8601)
        XCTAssertEqual(decoder.dataDecodingStrategy, .deferredToData)
        
        decoder.configured(with: .init(dateDecodingStrategy: .deferredToDate, dataDecodingStrategy: .base64))
        XCTAssertEqual(decoder.dateDecodingStrategy, .deferredToDate)
        XCTAssertEqual(decoder.dataDecodingStrategy, .base64)
        
        decoder.configured(with: .init(dateDecodingStrategy: .secondsSince1970, dataDecodingStrategy: .base64))
        XCTAssertEqual(decoder.dateDecodingStrategy, .secondsSince1970)
        XCTAssertEqual(decoder.dataDecodingStrategy, .base64)
        
        decoder.configured(with: .init(dateDecodingStrategy: .millisecondsSince1970, dataDecodingStrategy: .base64))
        XCTAssertEqual(decoder.dateDecodingStrategy, .millisecondsSince1970)
        XCTAssertEqual(decoder.dataDecodingStrategy, .base64)
        
        decoder.configured(with: .init(dateDecodingStrategy: .iso8601, dataDecodingStrategy: .base64))
        XCTAssertEqual(decoder.dateDecodingStrategy, .iso8601)
        XCTAssertEqual(decoder.dataDecodingStrategy, .base64)
    }
    
    func testEncodingStrategy() {
        let encoder = JSONEncoder()
        
        encoder.configured(with: .init(dateEncodingStrategy: .deferredToDate, dataEncodingStrategy: .deferredToData))
        XCTAssertEqual(encoder.dateEncodingStrategy, .deferredToDate)
        XCTAssertEqual(encoder.dataEncodingStrategy, .deferredToData)
        
        encoder.configured(with: .init(dateEncodingStrategy: .secondsSince1970, dataEncodingStrategy: .deferredToData))
        XCTAssertEqual(encoder.dateEncodingStrategy, .secondsSince1970)
        XCTAssertEqual(encoder.dataEncodingStrategy, .deferredToData)
        
        encoder.configured(with: .init(dateEncodingStrategy: .millisecondsSince1970, dataEncodingStrategy: .deferredToData))
        XCTAssertEqual(encoder.dateEncodingStrategy, .millisecondsSince1970)
        XCTAssertEqual(encoder.dataEncodingStrategy, .deferredToData)
        
        encoder.configured(with: .init(dateEncodingStrategy: .iso8601, dataEncodingStrategy: .deferredToData))
        XCTAssertEqual(encoder.dateEncodingStrategy, .iso8601)
        XCTAssertEqual(encoder.dataEncodingStrategy, .deferredToData)
        
        encoder.configured(with: .init(dateEncodingStrategy: .deferredToDate, dataEncodingStrategy: .base64))
        XCTAssertEqual(encoder.dateEncodingStrategy, .deferredToDate)
        XCTAssertEqual(encoder.dataEncodingStrategy, .base64)
        
        encoder.configured(with: .init(dateEncodingStrategy: .secondsSince1970, dataEncodingStrategy: .base64))
        XCTAssertEqual(encoder.dateEncodingStrategy, .secondsSince1970)
        XCTAssertEqual(encoder.dataEncodingStrategy, .base64)
        
        encoder.configured(with: .init(dateEncodingStrategy: .millisecondsSince1970, dataEncodingStrategy: .base64))
        XCTAssertEqual(encoder.dateEncodingStrategy, .millisecondsSince1970)
        XCTAssertEqual(encoder.dataEncodingStrategy, .base64)
        
        encoder.configured(with: .init(dateEncodingStrategy: .iso8601, dataEncodingStrategy: .base64))
        XCTAssertEqual(encoder.dateEncodingStrategy, .iso8601)
        XCTAssertEqual(encoder.dataEncodingStrategy, .base64)
    }
    
    private static let testEncoder = JSONEncoder()
    private static let testDecoder = JSONDecoder()
    
    func testApodiniMigratorCodable() {
        struct CodableStruct: ApodiniMigratorCodable {
            static var encoder = ApodiniMigratorSharedTests.testEncoder
            static var decoder = ApodiniMigratorSharedTests.testDecoder
            
            let prop1: String
            let prop2: String
        }
        
        let encoder = Self.testEncoder
        let decoder = Self.testDecoder
        
        XCTAssert([CodableStruct].encoder.dateEncodingStrategy == encoder.dateEncodingStrategy)
        XCTAssert([CodableStruct].encoder.dataEncodingStrategy == encoder.dataEncodingStrategy)

        XCTAssert([CodableStruct].decoder.dateDecodingStrategy == decoder.dateDecodingStrategy)
        XCTAssert([CodableStruct].decoder.dataDecodingStrategy == decoder.dataDecodingStrategy)

        encoder.configured(with: .init(dateEncodingStrategy: .millisecondsSince1970, dataEncodingStrategy: .base64))

        XCTAssert([Int: CodableStruct].encoder.dateEncodingStrategy == encoder.dateEncodingStrategy)
        XCTAssert([Int: CodableStruct].encoder.dataEncodingStrategy == encoder.dataEncodingStrategy)

        XCTAssert([String: CodableStruct].decoder.dateDecodingStrategy == decoder.dateDecodingStrategy)
        XCTAssert([String: CodableStruct].decoder.dataDecodingStrategy == decoder.dataDecodingStrategy)

        decoder.configured(with: .init(dateDecodingStrategy: .iso8601, dataDecodingStrategy: .deferredToData))

        XCTAssert(CodableStruct?.encoder.dateEncodingStrategy == encoder.dateEncodingStrategy)
        XCTAssert(CodableStruct?.encoder.dataEncodingStrategy == encoder.dataEncodingStrategy)

        XCTAssert(CodableStruct?.decoder.dateDecodingStrategy == decoder.dateDecodingStrategy)
        XCTAssert(CodableStruct?.decoder.dataDecodingStrategy == decoder.dataDecodingStrategy)
    }
    
    func testString() {
        let empty = ""
        XCTAssert(empty.lowerFirst == empty)
        XCTAssert(empty.upperFirst == empty)
        XCTAssert(empty.components(separatedBy: "\n").first == empty)
        
        let getEventsHandler = "GetEventsHandler"
        let events = "events"
        
        XCTAssertEqual(getEventsHandler.lowerFirst, "getEventsHandler")
        XCTAssertEqual(events.upperFirst, "Events")
        let optionalEvent = "Event?"
        XCTAssertEqual(optionalEvent.dropQuestionMark, "Event")
    }
    
    func testArray() {
        var numbers = [1, 2, 3, 4, 5, 6, 6, 6, 6, 7]
        let replaced = numbers.replacingOccurrences(ofElement: 6, with: 9)
        XCTAssert(!replaced.contains { $0 == 6 })
        numbers.replacingOccurrences(of: 6, with: 9)
        XCTAssert(numbers == replaced)
    }
}

extension JSONDecoder.DateDecodingStrategy: Equatable {
    public static func == (lhs: JSONDecoder.DateDecodingStrategy, rhs: JSONDecoder.DateDecodingStrategy) -> Bool {
        switch (lhs, rhs) {
        case (.deferredToDate, .deferredToDate):
            return true
        case (.secondsSince1970, .secondsSince1970):
            return true
        case (.millisecondsSince1970, .millisecondsSince1970):
            return true
        case (.iso8601, .iso8601):
            return true
        default:
            return false
        }
    }
}

extension JSONDecoder.DataDecodingStrategy: Equatable {
    public static func == (lhs: JSONDecoder.DataDecodingStrategy, rhs: JSONDecoder.DataDecodingStrategy) -> Bool {
        switch (lhs, rhs) {
        case (.deferredToData, .deferredToData):
            return true
        case (.base64, .base64):
            return true
        default:
            return false
        }
    }
}

extension JSONEncoder.DateEncodingStrategy: Equatable {
    public static func == (lhs: JSONEncoder.DateEncodingStrategy, rhs: JSONEncoder.DateEncodingStrategy) -> Bool {
        switch (lhs, rhs) {
        case (.deferredToDate, .deferredToDate):
            return true
        case (.secondsSince1970, .secondsSince1970):
            return true
        case (.millisecondsSince1970, .millisecondsSince1970):
            return true
        case (.iso8601, .iso8601):
            return true
        default:
            return false
        }
    }
}

extension JSONEncoder.DataEncodingStrategy: Equatable {
    public static func == (lhs: JSONEncoder.DataEncodingStrategy, rhs: JSONEncoder.DataEncodingStrategy) -> Bool {
        switch (lhs, rhs) {
        case (.deferredToData, .deferredToData):
            return true
        case (.base64, .base64):
            return true
        default:
            return false
        }
    }
}
