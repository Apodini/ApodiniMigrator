

import Foundation

extension String {
    /// `self` wrapped with apostrophes complying to json strings
    var asString: String {
        "\"\(self)\""
    }
    
    func split(character: Character) -> [String] {
        split(separator: character).map { String($0) }
    }
}
