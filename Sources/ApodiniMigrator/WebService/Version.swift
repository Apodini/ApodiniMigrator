import Foundation

/** Version from Apodini */

/// A `Version` can be  used to specify the version of a Web API using semantic versioning
public struct Version: Value {
    /// Default values for a `Version`
    public enum Defaults {
        /// The default prefix
        public static let prefix: String = "v"
        /// The default major version
        public static let major: UInt = 1
        /// The default major minor
        public static let minor: UInt = 0
        /// The default major patch
        public static let patch: UInt = 0
    }
    
    
    /// The version prefix
    public let prefix: String
    /// The major version number
    public let major: UInt
    /// The minor version number
    public let minor: UInt
    /// The patch version number
    public let patch: UInt
    
    
    /// - Parameters:
    ///   - prefix: The version prefix
    ///   - major: The major version number
    ///   - minor: The minor version number
    ///   - patch: The patch version number
    public init(
        prefix: String = Defaults.prefix,
        major: UInt = Defaults.major,
        minor: UInt = Defaults.minor,
        patch: UInt = Defaults.patch
    ) {
        self.prefix = prefix
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    /// Encodes self into the given encoder
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(prefix)_\(major).\(minor).\(patch)")
    }
    
    /// Initializes self from the given decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        
        let components = string.split(string: "_")
        let prefix = components.first
        let numbers = components.last?.split(string: ".")
        
        if
            let prefix = prefix,
            let numbers = numbers,
            numbers.count == 3
        {
            self.prefix = prefix
            self.major = UInt(numbers[0]) ?? 0
            self.minor = UInt(numbers[1]) ?? 0
            self.patch = UInt(numbers[2]) ?? 0
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Failed to decode \(Self.self)")
        }
    }
    
    /// Default version
    public static var `default`: Version {
        .init()
    }
}

extension Version: CustomStringConvertible {
    /// String representation of the version
    public var description: String {
        "\(prefix)\(major)"
    }
}
