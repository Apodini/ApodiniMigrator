import Foundation
import Combine

/// A `typealias` of `AnyPublisher` where `Output` conforms to `Decodable` (`ApodiniMigratorDecodable`)
public typealias ApodiniPublisher<D> = AnyPublisher<D, Error> where D: Decodable

/// A caseless enum used for handling network requests
public enum NetworkingService {
    /// A configuration object for a `JSONDecoder`
    private static let decoderConfiguration = DecoderConfiguration(
        ___decoder___configuration___
    )
    
    /// A configuration object for a `JSONEncoder`
    private static let encoderConfiguration = EncoderConfiguration(
        ___encoder___configuration___
    )
    
    /// `JSONDecoder` used for decoding responses of an Apodini web service
    static let decoder = JSONDecoder().configured(with: decoderConfiguration)
    
    /// `JSONEncoder` used for encoding request bodies for an Apodini web service
    static let encoder = JSONEncoder().configured(with: encoderConfiguration)
    
    /// BaseURL of the web service
    static var baseURL: URL = {
        guard let baseURL = URL(string: "___serverpath___") else {
            fatalError("Could not create the base URL for the Web Service")
        }
        return baseURL
    }()
    
    /// Triggers a request via a client `Handler` to a handler of an `Apodini` web service
    /// - Parameters:
    ///    - handler: client-side handler representation for which the request will be triggered
    ///    - baseURL: baseURL of the web service, where the handler is located, default value `NetworkingService.baseURL`
    static func trigger<D: Decodable>(_ handler: Handler<D>, at baseURL: URL = baseURL) -> ApodiniPublisher<D> {
        URLSession.shared.dataTaskPublisher(for: URLRequest(for: handler, with: baseURL))
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
        .decode(type: DataWrapper<D>.self, decoder: decoder)
        .map(\.data)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    /// Encodes an instance of the indicated type with `NetworkingService.encoder`
    static func encode<E: Encodable>(_ value: E?) -> Data? {
        try? encoder.encode(value)
    }
}

/// NetworkingService extension
fileprivate extension NetworkingService {
    /// A util object to decode a Restful response of an Apodini web service
    struct DataWrapper<D: Decodable>: Decodable {
        // MARK: Private Inner Types
        private enum CodingKeys: String, CodingKey {
            case links = "_links"
            case data
        }
        
        let links: [String: String]
        let data: D
    }
}
