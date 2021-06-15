import Foundation
import PathKit

// MARK: - Encodable extensions
public extension Encodable {
    /// JSON String of this encodable with `.prettyPrinted` and `.withoutEscapingSlashes` output formatting
    var json: String {
        json(with: [.prettyPrinted, .withoutEscapingSlashes])
    }
    
    /// JSON String of this encodable
    /// - Parameters:
    ///     - outputFormatting: The output formatting options that determine the readability, size, and element order of an encoded JSON object.
    func json(with outputFormatting: JSONEncoder.OutputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = outputFormatting
        let data = (try? encoder.encode(self)) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }
    
    /// Writes `json` of self at the specified path
    func write(at path: Path, fileName: String? = nil) {
        try? (path + "\(fileName ?? String(describing: type(of: self))).json").write(json)
    }
}

// MARK: - KeyedEncodingContainerProtocol
extension KeyedEncodingContainerProtocol {
    /// Only encodes the value if the collection is not empty
    public mutating func encodeIfNotEmpty<T: Encodable>(_ value: T, forKey key: Key) throws where T: Collection, T.Element: Encodable {
        if !value.isEmpty {
            try encode(value, forKey: key)
        }
    }
}
