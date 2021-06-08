import Foundation
import PathKit

// MARK: - Encodable extensions
public extension Encodable {
    /// JSON String of this encodable with `.prettyPrinted` output formatting
    var json: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
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
