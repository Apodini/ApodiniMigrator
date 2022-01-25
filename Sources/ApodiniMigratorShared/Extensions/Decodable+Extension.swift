//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
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
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "`ApodiniMigrator` only supports decoding of files in either json or yaml format: \"\(path)\""
                )
            )
        }
        let data = try path.read() as Data
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
