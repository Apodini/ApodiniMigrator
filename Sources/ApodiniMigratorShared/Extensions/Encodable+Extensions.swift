//
//  Encodable+Extensions.swift
//  ApodiniMigratorShared
//
//  Created by Eldi Cano on 27.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
@_implementationOnly import FineJSON
@_implementationOnly import RichJSONParser
import PathKit

// MARK: - Encodable extensions
public extension Encodable {
    /// JSON String of this encodable
    var json: String {
        json()
    }
    
    /// JSON String of this encodable
    /// - Parameters:
    ///     - prettyPrinted: Pretty printed format, true by default
    ///     - indentation: Indentation, by default 4
    func json(prettyPrinted: Bool = true, indentation: UInt = 4) -> String {
        let encoder = FineJSONEncoder()
        encoder.jsonSerializeOptions = JSONSerializeOptions(
            isPrettyPrint: prettyPrinted,
            indentString: String(repeating: " ", count: Int(indentation))
        )
        let data = (try? encoder.encode(self)) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }
    
    /// Writes `json` of self at the specified path
    func write(at path: Path, fileName: String? = nil) {
        try? (path + "\(fileName ?? String(describing: Self.self)).json").write(json)
    }
}

// MARK: - KeyedEncodingContainerProtocol
extension KeyedEncodingContainerProtocol {
    /// Only encodes the value if the collection is not empty
    public mutating func encodeIfNotEmpty<T: Encodable>(_ value: T, forKey key: Key) throws where T: Collection, T.Element: Encodable {
        if !value.isEmpty {
            try encode(value, forKey: key)
        }
    }
}
