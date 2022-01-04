import Foundation

/// Represents distinct `HTTPMethod` cases
public enum HTTPMethod: String {
    /// A `CONNECT` `HTTPMethod`
    case connect
    /// A `DELETE` `HTTPMethod`
    case delete
    /// A `GET` `HTTPMethod`
    case get
    /// A `HEAD` `HTTPMethod`
    case head
    /// An `OPTIONS` `HTTPMethod`
    case options
    /// A `PATCH` `HTTPMethod`
    case patch
    /// A `POST` `HTTPMethod`
    case post
    /// A `PUT` `HTTPMethod`
    case put
    /// A `TRACE` `HTTPMethod`
    case trace
    
    /// String representation of a `HTTPMethod` as expected from a `URLRequest`
    public var string: String {
        rawValue.uppercased()
    }
}
