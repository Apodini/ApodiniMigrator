//
//  Decodable+Extension.swift
//  ApodiniMigratorShared
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import PathKit
@_implementationOnly import Yams

public extension Decodable {
    /// Initializes self from data
    static func decode(from data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
    
    /// Initializes self from string
    static func decode(from string: String) throws -> Self {
        try decode(from: string.data())
    }
    
    /// Initializes self from the content of path
    static func decode(from path: Path) throws -> Self {
        guard path.is(.json) || path.is(.yaml) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "`ApodiniMigrator` only supports decoding of files in either json or yaml format"))
        }
        let data: Data = try path.read()
        if path.is(.yaml) {
            return try YAMLDecoder().decode(from: data)
        }
        return try decode(from: data)
    }
}

// MARK: - KeyedDecodingContainerProtocol
extension KeyedDecodingContainerProtocol {
    /// Decodes a value of the given collection type for the given key, if present, otherwise initalizes it as empty collection
    public func decodeIfPresentOrInitEmpty<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T where T: Collection, T.Element: Decodable {
        // swiftlint:disable:next force_cast
        (try decodeIfPresent(T.self, forKey: key)) ?? [] as! T
    }
}
