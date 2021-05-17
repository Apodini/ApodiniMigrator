import Foundation

/// A protocol that forces the presence of an empty initializer
public protocol DefaultInitializable: Encodable {
    init()
    static var jsonString: String { get }
}

// MARK: - Default
public extension DefaultInitializable {
    static var defaultValue: Self { .init() }
    static var jsonString: String { defaultValue.json }
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
extension Data: DefaultInitializable {}
extension String: DefaultInitializable {}

extension URL: DefaultInitializable {
    public static var defaultURL: URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://github.com/Apodini/ApodiniMigrator.git")!
    }
    
    public init() {
        self = .defaultURL
    }
}

extension UUID: DefaultInitializable {
    public static var defaultValue: UUID { defaultUUID }
    
    public static var defaultUUID: UUID {
        UUID(uuidString: "3070B293-C664-412B-A43E-21FF445608B7") ?? UUID()
    }
}

extension Date: DefaultInitializable {
    var noon: Date {
        Calendar(identifier: .gregorian).date(bySettingHour: 12, minute: 0, second: 0, of: self) ?? self
    }
    
    public static var today: Date { Date().noon }
    
    public static var defaultValue: Self { today }
}
