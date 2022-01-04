//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A custom `DateEncodingStrategy` of `JSONEncoder`
/// - Note: Does not support `.formatted` and `.custom` cases of `JSONEncoder`
public enum DateEncodingStrategy: String, Codable, Hashable {
    /// Defer to `Date` for choosing an encoding. This is the default strategy.
    case deferredToDate

    /// Encode the `Date` as a UNIX timestamp (as a JSON number).
    case secondsSince1970

    /// Encode the `Date` as UNIX millisecond timestamp (as a JSON number).
    case millisecondsSince1970

    /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format) on available platforms. If not available, `.deferredToDate` is used
    case iso8601

    /// Corresponding strategy of `JSONEncoder`
    fileprivate var toJSONEncoderStrategy: JSONEncoder.DateEncodingStrategy {
        switch self {
        case .deferredToDate: return .deferredToDate
        case .secondsSince1970: return .secondsSince1970
        case .millisecondsSince1970: return .millisecondsSince1970
        case .iso8601:
            if #available(iOS 10, *) {
                return .iso8601
            } else {
                return .deferredToDate
            }
        }
    }
}

/// A custom `DataEncodingStrategy` of `JSONEncoder`
/// - Note: Does not support `.custom` case `JSONEncoder`
public enum DataEncodingStrategy: String, Codable, Equatable {
    /// Defer to `Data` for choosing an encoding.
    case deferredToData

    /// Encodes the `Data` as a Base64-encoded string. This is the default strategy.
    case base64
    
    /// Corresponding strategy of `JSONEncoder`
    fileprivate var toJSONEncoderStrategy: JSONEncoder.DataEncodingStrategy {
        switch self {
        case .deferredToData: return .deferredToData
        case .base64: return .base64
        }
    }
}

/// A configuration object for `JSONEncoder`
public struct EncoderConfiguration: Codable, Hashable {
    /// `dateEncodingStrategy` to be set to a `JSONEncoder`
    public let dateEncodingStrategy: DateEncodingStrategy
    /// `dataEncodingStrategy` to be set to a `JSONEncoder`
    public let dataEncodingStrategy: DataEncodingStrategy
    
    /// Initializer of a `EncoderConfiguration` instance
    public init(dateEncodingStrategy: DateEncodingStrategy, dataEncodingStrategy: DataEncodingStrategy) {
        self.dateEncodingStrategy = dateEncodingStrategy
        self.dataEncodingStrategy = dataEncodingStrategy
    }
    
    /// `default` configuration of a `JSONEncoder`
    public static var `default`: EncoderConfiguration {
        .init(dateEncodingStrategy: .deferredToDate, dataEncodingStrategy: .base64)
    }
}

/// JSONEncoder extension
public extension JSONEncoder {
    /// Configures `self` with the properties of `EncoderConfiguration`
    @discardableResult
    func configured(with configuration: EncoderConfiguration) -> JSONEncoder {
        dateEncodingStrategy = configuration.dateEncodingStrategy.toJSONEncoderStrategy
        dataEncodingStrategy = configuration.dataEncodingStrategy.toJSONEncoderStrategy
        return self
    }
}
