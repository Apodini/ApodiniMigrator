import Foundation

/// The `HTTPAuthorization` request header
public struct HTTPAuthorization {
    /// Location of the authorization
    public enum Location {
        case header
        case query
        case cookie
    }
    
    /// Initializer for `HTTPAuthorization`
    public init(location: Location, value: String) {
        self.location = location
        self.key = "Authorization"
        self.value = value
    }
    
    /// Location of the authorization
    public let location: Location
    /// The key of the authorization header
    /// - Note: always `Authorization`
    public let key: String
    /// The value of the `Authorization`, e.g. `Basic SGVsbG8gQXBvZGluaU1pZ3JhdG9yIERldmVsb3BlciE=`
    public let value: String
    
    /// String representation of the `HTTPAuthorization` as a query
    var query: String {
        key + "=" + value
    }
    
    /// Updates `headers` with own `key`-`value` pair
    func inject(into headers: inout HTTPHeaders) {
        headers[key] = value
    }
}

/// HTTPAuthorization convenience
public extension HTTPAuthorization {
    /// A basic `HTTPAuthorization`
    /// - Parameters:
    ///     - username: username
    ///     - password: password
    /// - Note: encodes `username` and `password` in Base-64 encoded string (a basic `HTTPAuthorization` conforming way)
    /// - Returns: a basic `HTTPAuthorization`, with location always `.header`
    static func basic(_ username: String, _ password: String) -> HTTPAuthorization {
        let string = [username, password].joined(separator: ":")
        let base64EncodedString = string.data(using: .utf8)?.base64EncodedString() ?? ""
        return .init(location: .header, value: "Basic \(base64EncodedString)")
    }
    
    /// A Bearer `HTTPAuthorization`
    /// - Parameters:
    ///     - token: token
    /// - Note: `Bearer ` already included in the value
    static func bearer(_ token: String) -> HTTPAuthorization {
        .init(location: .header, value: "Bearer \(token)")
    }
    
    /// A custom `HTTPAuthorization`
    static func authorization(_ value: String?) -> HTTPAuthorization? {
        if let value = value {
            return .init(location: .header, value: value)
        }
        return nil
    }
    
    /// `HTTPAuthorization` if `NetworkingService.authorization` is set
    static func networkingService() -> HTTPAuthorization? {
        .authorization(NetworkingService.authorization)
    }
}
