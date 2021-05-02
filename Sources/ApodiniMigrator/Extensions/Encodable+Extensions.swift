import Foundation

extension Encodable {
    var json: String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.iSO8601DateFormatter)
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = (try? encoder.encode(self)) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }
}
