//
//  Encodable+Extensions.swift
//  ApodiniMigratorShared
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
@_implementationOnly import FineJSON
@_implementationOnly import RichJSONParser
@_implementationOnly import Yams
import PathKit

// MARK: - Encodable extensions
public extension Encodable {
    /// JSON String of this encodable
    var json: String {
        json()
    }
    
    /// YAML String of this encodable
    var yaml: String {
        (try? YAMLEncoder().encode(self)) ?? ""
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
    
    /// Writes self at the specified path with the defined format
    @discardableResult
    func write(at path: String, outputFormat: OutputFormat = .json, fileName: String? = nil) throws -> String {
        let location = path.asPath
        try location.mkpath()
        let filePath = location + "\(fileName ?? String(describing: Self.self)).\(outputFormat.rawValue)"
        try filePath.write(outputFormat.string(of: self))
        return filePath.absolute().string
    }
}

// MARK: - KeyedEncodingContainerProtocol
extension KeyedEncodingContainerProtocol {
    /// Only encodes the value if the collection is not empty
    public mutating func encodeIfNotEmpty<T: Encodable>(_ value: T, forKey key: Key) throws where T: Collection, T.Element: Encodable {
        if value.isNotEmpty {
            try encode(value, forKey: key)
        }
    }
}
