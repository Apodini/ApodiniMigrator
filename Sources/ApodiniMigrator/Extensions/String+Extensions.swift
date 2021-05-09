import Foundation

extension String {
    /// Line break
    static var lineBreak: String {
        "\n"
    }
    
    /// `self` wrapped with apostrophes complying to json strings
    var asString: String {
        "\"\(self)\""
    }
    
    /// Return the string with a uppercased first character
    var upperFirst: String {
        if let first = first {
            return first.uppercased() + dropFirst()
        }
        return self
    }
    
    /// Splits the string by a character and returns the result as a String array
    func split(character: Character) -> [String] {
        split(separator: character).map { String($0) }
    }
    
    /// Splits `self` by the passed string
    /// - Parameters:
    ///      - string: separator
    ///      - ignoreEmptyComponents: flag whether empty components should be ignored, `false` by default
    /// - Returns: the array of string components
    func split(string: String, ignoreEmptyComponents: Bool = false) -> [String] {
        components(separatedBy: string).filter { ignoreEmptyComponents ? !$0.isEmpty : true }
    }
    
    func sanitizedLines() -> [String] {
        // splitting the string, empty lines are mapped into empty string array elements
        split(string: .lineBreak).reduce(into: [String]()) { result, current in
            let trimmed = current.trimmingCharacters(in: .whitespaces)
            if !(result.last?.isEmpty == true && trimmed.isEmpty) { // not allowing double empty lines
                result.append(trimmed)
            }
        }
    }
}

extension Collection where Element == String {
    func withBreakingLines() -> String {
        joined(separator: .lineBreak)
    }
}
