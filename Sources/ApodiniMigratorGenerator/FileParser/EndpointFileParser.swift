//
//  File.swift
//  
//
//  Created by Eldi Cano on 22.05.21.
//

import Foundation

struct ParsedMethodSection: Equatable {
    let markComment: MARKComment
    var lines: [String]
}

extension Array where Element == ParsedMethodSection {
    func allSections() -> [String] {
        sorted(by: \.markComment).map { $0.lines }.flatMap { $0 }
    }
}

/// An endpoint file parser
struct EndpointFileParser: FileParser {
    /// The path where the file is located
    let path: Path
    
    /// Parsed method sections of the file
    var methods: [ParsedMethodSection] = []
    
    /// String array of the header of the file
    var header: [String]
    
    var sections: Sections {
        [header, methods.allSections()]
    }
    
    /// Initializes the parser with a file at the specified path
    init(path: Path) throws {
        self.path = path
        let lines = try path.read().sanitizedLines()
        
        let markComments = lines
            .compactMap { MARKComment(from: $0) }
            .sorted()
            .filter { $0 != .init(.endpoints) }
        
        precondition(!markComments.isEmpty, "Encountered a malformed endpoints file")
        
        let firstMARKComment = markComments[0]
        
        header = Self.sublines(in: lines, to: firstMARKComment)
        
        switch markComments.count {
        case 1: methods = [.init(markComment: firstMARKComment, lines: Self.sublines(in: lines, from: firstMARKComment))]
        default:
            markComments.enumerated().forEach { index, comment in
                let methodSection = ParsedMethodSection(
                    markComment: comment,
                    lines: Self.sublines(in: lines, from: comment, to: comment == markComments.last ? nil : markComments[index + 1])
                )
                methods.append(methodSection)
            }
        }
    }
}

extension MARKComment {
    init?(from line: String) {
        if line.contains(Self.base) {
            self.init(line)
        } else {
            return nil
        }
    }
}
