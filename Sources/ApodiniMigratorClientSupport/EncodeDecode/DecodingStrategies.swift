//
//  File.swift
//  
//
//  Created by Eldi Cano on 17.05.21.
//

import Foundation

/// A custom `DateEncodingStrategy` of `JSONDecoder`
/// - Note: Does not support `.formatted` and `.custom` cases of `JSONDecoder`
public enum DateDecodingStrategy {
    /// Defer to `Date` for decoding. This is the default strategy.
    case deferredToDate

    /// Decode the `Date` as a UNIX timestamp from a JSON number.
    case secondsSince1970

    /// Decode the `Date` as UNIX millisecond timestamp from a JSON number.
    case millisecondsSince1970

    /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    /// - Note: Libraries of `ApodiniMigrator` are built for macOS 10.15, therefore this decoding strategy can be used without restriction
    case iso8601

    /// Corresponding strategy of `JSONDecoder`
    fileprivate var toJSONDecoderStrategy: JSONDecoder.DateDecodingStrategy {
        switch self {
        case .deferredToDate: return .deferredToDate
        case .secondsSince1970: return .secondsSince1970
        case .millisecondsSince1970: return .millisecondsSince1970
        case .iso8601: return .iso8601
        }
    }
}

/// A custom `DataDecodingStrategy` of `JSONDecoder`
/// - Note: Does not support `.custom` case `JSONDecoder`
public enum DataDecodingStrategy {
    /// Defer to `Data` for decoding.
    case deferredToData

    /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
    case base64

    /// Corresponding strategy of `JSONDecoder`
    fileprivate var toJSONDecoderStrategy: JSONDecoder.DataDecodingStrategy {
        switch self {
        case .deferredToData: return .deferredToData
        case .base64: return .base64
        }
    }
}

/// A configuration object for `JSONDecoder`
public struct DecoderConfiguration {
    /// `dateEncodingStrategy` to be set to a `JSONDecoder`
    let dateDecodingStrategy: DateDecodingStrategy
    /// `dataEncodingStrategy` to be set to a `JSONDecoder`
    let dataDecodingStrategy: DataDecodingStrategy
    
    
    /// Initializer of a `DecoderConfiguration` instance
    public init(dateDecodingStrategy: DateDecodingStrategy, dataDecodingStrategy: DataDecodingStrategy) {
        self.dateDecodingStrategy = dateDecodingStrategy
        self.dataDecodingStrategy = dataDecodingStrategy
    }
    
    /// `default` configuration of a `JSONDecoder`
    public static var `default`: DecoderConfiguration {
        .init(dateDecodingStrategy: .deferredToDate, dataDecodingStrategy: .base64)
    }
}

/// JSONDecoder extension
public extension JSONDecoder {
    /// Configures `self` with the properties of `DecoderConfiguration`
    func configured(with configuration: DecoderConfiguration) -> JSONDecoder {
        dateDecodingStrategy = configuration.dateDecodingStrategy.toJSONDecoderStrategy
        dataDecodingStrategy = configuration.dataDecodingStrategy.toJSONDecoderStrategy
        return self
    }
}
