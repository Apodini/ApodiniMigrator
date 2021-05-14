import Foundation

/// A protocol that forces the presence of an empty initializer
public protocol DefaultInitializable: CustomStringConvertible {
    init()
    static var jsonString: String { get }
}

// MARK: - Default
public extension DefaultInitializable {
    static var defaultValue: Self { .init() }
    static var jsonString: String { defaultValue.description }
    static func jsonString(_ optionalValue: Self?) -> String {
        optionalValue?.description ?? jsonString
    }
}

// MARK: - DefaultInitializable conformance
extension Int: DefaultInitializable {}
extension Int8: DefaultInitializable {}
extension Int16: DefaultInitializable {}
extension Int32: DefaultInitializable {}
extension Int64: DefaultInitializable {}
extension UInt: DefaultInitializable {}
extension UInt8: DefaultInitializable {}
extension UInt16: DefaultInitializable {}
extension UInt32: DefaultInitializable {}
extension UInt64: DefaultInitializable {}
extension Bool: DefaultInitializable {}
extension Double: DefaultInitializable {}
extension Float: DefaultInitializable {}

extension String: DefaultInitializable {
    public static var jsonString: String {
        defaultValue.description.asString
    }
    public static func jsonString(_ optionalValue: Self?) -> String {
        optionalValue?.description.asString ?? jsonString
    }
}

extension URL: DefaultInitializable {
    static var defaultURL: URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://github.com/Apodini/ApodiniMigrator.git")!
    }
    
    public init() {
        self = .defaultURL
    }
    
    public static var jsonString: String {
        defaultValue.absoluteString.asString
    }
}

extension UUID: DefaultInitializable {
    public static var jsonString: String {
        defaultUUID.uuidString.asString
    }
    
    static var defaultUUID: UUID {
        UUID(uuidString: "3070B293-C664-412B-A43E-21FF445608B7") ?? UUID()
    }
}

extension Date: DefaultInitializable {
    var noon: Date {
        Calendar(identifier: .gregorian).date(bySettingHour: 12, minute: 0, second: 0, of: self) ?? self
    }
    
    static var today: Date {
        Date().noon
    }
    
    public static var jsonString: String {
        DateFormatter.iSO8601DateFormatter.string(from: today).asString
    }
}
extension Data: DefaultInitializable {
    public static var jsonString: String {
        Data().base64EncodedString().asString
    }
}
