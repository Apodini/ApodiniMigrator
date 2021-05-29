import Foundation

// MARK: - Encodable extensions
public extension Encodable {
    /// JSON String of this encodable with `.prettyPrinted` output formatting
    var json: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let data = (try? encoder.encode(self)) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }
}
