import Foundation

/// An error object representing `@Throws` of Apodini
public struct ApodiniError: Error {
    /// `statusCode` of the error
    public let code: Int
    /// A descriptive message associated with the error
    public let message: String
    
    /// Initializer for a new `ApodiniError` instance
    /// - Parameters:
    ///     - code: `code` of the error
    ///     - message: descriptive message associated with the error
    public init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}

/// Array extension for `ApodiniError` support
public extension Array where Element == ApodiniError {
    /// Appends a new `ApodiniError` to `self`
    /// - Parameters:
    ///     - code: `statusCode` of the error
    ///     - message: descriptive message associated with the error
    mutating func addError(_ code: Int, message: String) {
        append(.init(code: code, message: message))
    }
}
