import Foundation

protocol DefaultInitializable: CustomStringConvertible {
    init()
    static var jsonString: String { get }
}
extension DefaultInitializable {
    static var defaultValue: Self { .init() }
    static var jsonString: String { defaultValue.description }
    static func jsonString(_ optionalValue: Self?) -> String {
        optionalValue?.description ?? jsonString
    }
}

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
    static var jsonString: String {
        defaultValue.description.asString
    }
    static func jsonString(_ optionalValue: Self?) -> String {
        optionalValue?.description.asString ?? jsonString
    }
}

extension UUID: DefaultInitializable {
    static var jsonString: String {
        test.uuidString.asString
    }
    
    static var test: UUID {
        UUID(uuidString: "3070B293-C664-412B-A43E-21FF445608B7") ?? UUID()
    }
}

extension Date: DefaultInitializable {
    var noon: Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(bySettingHour: 12, minute: 0, second: 0, of: self) ?? self
    }
    
    static var test: Date {
        Date().noon
    }
    static var jsonString: String {
        DateFormatter.iSO8601DateFormatter.string(from: test).asString
    }
}
extension Data: DefaultInitializable {
    static var jsonString: String {
        Data().base64EncodedString().asString
    }
}
