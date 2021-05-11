import Foundation

// MARK: - Encodable extensions
extension Encodable {
    /// JSON String of this encodable with `.prettyPrinted, .sortedKeys, .withoutEscapingSlashes` output formatting
    /// and `iSO8601DateFormatter` as date encoding strategy
    var json: String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.iSO8601DateFormatter)
        encoder.dataEncodingStrategy = .base64
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = (try? encoder.encode(self)) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }
}
