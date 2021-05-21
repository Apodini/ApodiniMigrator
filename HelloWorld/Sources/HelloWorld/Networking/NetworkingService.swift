//
//  NetworkingService.swift
//
//  Created by ApodiniMigrator on 21.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import Combine

/// A `typealias` of `AnyPublisher` where `Output` conforms to `Decodable` (`ApodiniMigratorDecodable`)
public typealias ApodiniPublisher<D> = AnyPublisher<D, Error> where D: Decodable

/// A caseless enum used for handling network requests
public enum NetworkingService {
    /// A configuration object for a `JSONDecoder`
    private static let decoderConfiguration = DecoderConfiguration(
        dateDecodingStrategy: .deferredToDate,
        dataDecodingStrategy: .base64
    )
    
    /// A configuration object for a `JSONEncoder`
    private static let encoderConfiguration = EncoderConfiguration(
        dateEncodingStrategy: .deferredToDate,
        dataEncodingStrategy: .base64
    )
    
    /// `JSONDecoder` used for decoding responses of an Apodini web service
    static let decoder = JSONDecoder().configured(with: decoderConfiguration)
    
    /// `JSONEncoder` used for encoding request bodies for an Apodini web service
    static let encoder = JSONEncoder().configured(with: encoderConfiguration)
    
    /// String path of the web service
    static let basePath = "http://0.0.0.0:8080"
    
    /// Triggers a request via a client `Handler` to a handler of an `Apodini` web service
    /// - Parameters:
    ///    - handler: client-side handler representation for which the request will be triggered
    ///    - path: base path of the web service, where the handler is located, default value `NetworkingService.path`
    static func trigger<D: Decodable>(_ handler: Handler<D>, at path: String = basePath) -> ApodiniPublisher<D> {
        URLSession.shared.dataTaskPublisher(for: URLRequest(for: handler, with: path))
        .tryMap { data, response in
            guard let response = response as? HTTPURLResponse else {
                return data
            }
            
            let statusCode = response.statusCode
            
            if 200 ... 299 ~= statusCode {
                return data
            }
            
            if let handlerError = handler.error(with: statusCode) {
                throw handlerError
            }
            
            throw URLError(.init(rawValue: statusCode))
        }
        .decode(type: D.self, decoder: decoder)
        .eraseToAnyPublisher()
    }
    
    /// Encodes an instance of the indicated type with `NetworkingService.encoder`
    static func encode<E: Encodable>(_ value: E?) -> Data? {
        try? encoder.encode(value)
    }
}

