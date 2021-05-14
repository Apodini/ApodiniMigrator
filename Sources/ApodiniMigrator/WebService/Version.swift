import Foundation

/** Version from Apodini */

/// A `Version` can be  used to specify the version of a Web API using semantic versioning
public struct Version: Codable {
    /// Default values for a `Version`
    enum Defaults {
        /// The default prefix
        static let prefix: String = "v"
        /// The default major version
        static let major: UInt = 1
        /// The default major minor
        static let minor: UInt = 0
        /// The default major patch
        static let patch: UInt = 0
    }
    
    
    /// The version prefix
    let prefix: String
    /// The major version number
    let major: UInt
    /// The minor version number
    let minor: UInt
    /// The patch version number
    let patch: UInt
    
    
    /// - Parameters:
    ///   - prefix: The version prefix
    ///   - major: The major version number
    ///   - minor: The minor version number
    ///   - patch: The patch version number
    init(
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
    
    static var `default`: Version {
        .init()
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        "\(prefix)\(major)"
    }
}
