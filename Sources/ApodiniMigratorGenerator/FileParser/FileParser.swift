//
//  File.swift
//  
//
//  Created by Eldi Cano on 10.05.21.
//

import Foundation

protocol FileParser {
    typealias Sections = [[String]]
    var path: Path { get }
    var sections: Sections { get }
}

extension FileParser {
    /// Saves and persists the updated file content
    func save() throws {
        let reconstructed = sections
            .flatMap { $0 }
            .lineBreaked
            .formatted(with: IndentationFormatter.self)
        
        try path.write(reconstructed)
    }
    
    static func sublines(in lines: [String], from: MARKComment? = nil, to: MARKComment? = nil) -> [String] {
        var fromIndex = lines.startIndex
        var toIndex = lines.endIndex
        
        if let from = from, let fromCommentIndex = lines.firstIndex(of: from.description) {
            fromIndex = fromCommentIndex
        }
        
        if let to = to, let toCommentIndex = lines.firstIndex(of: to.description) {
            toIndex = toCommentIndex
        }
        
        return Array(lines[min(fromIndex, toIndex) ..< max(fromIndex, toIndex)])
    }
    
    static func sublines(in lines: [String], from: MARKCommentType? = nil, to: MARKCommentType? = nil) -> [String] {
        var fromMarkComment: MARKComment?
        var toMarkComment: MARKComment?
        if let from = from {
            fromMarkComment = .init(from)
        }
        
        if let to = to {
            toMarkComment = .init(to)
        }
        
        return sublines(in: lines, from: fromMarkComment, to: toMarkComment)
    }
}
