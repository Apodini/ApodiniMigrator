//
//  Decodable+Extension.swift
//  ApodiniMigratorShared
//
//  Created by Eldi Cano on 29.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import PathKit

public extension Decodable {
    /// Initializes self from data
    static func decode(from data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
    
    static func decode(from url: URL) throws -> Self {
        try decode(from: try Data(contentsOf: url))
    }
    
    /// Initializes self from string
    static func decode(from string: String) throws -> Self {
        try decode(from: string.data(using: .utf8) ?? Data())
    }
    
    /// Initializes self from the content of path
    static func decode(from path: Path) throws -> Self {
        try decode(from: try path.read() as Data)
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
