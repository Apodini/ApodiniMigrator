//
//  File.swift
//  
//
//  Created by Eldi Cano on 10.05.21.
//

import Foundation

struct ParsedEnumCase: Equatable {
    let caseName: String
    let rawValue: String
    
    init(caseName: String, rawValue: String) {
        self.caseName = caseName
        self.rawValue = rawValue
    }
    
    init?(from line: String) {
        if line.contains("case "), line.contains("=") {
            let sanitized = line
                .without("case ")
                .split(character: "=")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            guard sanitized.count == 2, let caseName = sanitized.first, let rawValue = sanitized.last else {
                return nil
            }
            
            self.init(caseName: caseName, rawValue: rawValue.without("\""))
        } else {
            return nil
        }
        
    }
}

protocol FileParser {}

extension FileParser {
    static func sublines(in lines: [String], from: MARKCommentType, to: MARKCommentType? = nil) -> [String] {
        let fromComment = MARKComment(from).description
        var toIndex = lines.endIndex
        if let to = to, let commentIndex = lines.firstIndex(of: MARKComment(to).description) {
            toIndex = commentIndex
        }
        if let fromIndex = lines.firstIndex(of: fromComment) {
            return Array(lines[min(fromIndex, toIndex) ..< max(fromIndex, toIndex)])
        }
        return lines
    }
}
