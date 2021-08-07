//
//  SwiftFile.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Distinct file / object types
enum Kind: String {
    case `struct`
    case `class`
    case `enum`
    case `extension`
    
    /// Signature of `self`, classes are marked with `final` keyword
    var signature: String {
        "public \(self == .class ? "final " : "")\(rawValue)"
    }
}

/// A protocol that template models can conform to
protocol SwiftFile: Renderable {
    /// The `typeInformation` for which the template will be created
    var typeInformation: TypeInformation { get }
    
    /// The type of the content of the file
    var kind: Kind { get }
}

/// Distinct cases of mark comments that might appear in a file
enum MARKCommentType: String {
    case model
    case deprecated
    case codingKeys
    case properties
    case initializer
    case encodable
    case decodable
    case utils
    case endpoints
    
    var comment: String {
        rawValue.upperFirst
    }
}

/// `SwiftFileTemplate` default implementations
extension SwiftFile {
    /// The string of the type name of the `typeInformation`, without the name of the module
    var typeNameString: String {
        typeInformation.typeName.name
    }
    
    /// File extension
    /// - Note: always `.swift`
    var fileExtension: FileExtension { .swift }
    
    /// File name constructed from the type name and the file extension
    var fileName: String { "\(typeNameString).\(fileExtension)" }
    
    /// File comment in the header of the `Swift` file
    var fileComment: String {
        FileHeaderComment(fileName: fileName).render()
    }
    
    /// Writes the content of `render()` method at the specified path, formatted with `IndentationFormatter`
    /// - Parameter directory: The path of directory where the content should be written
    /// - Throws: if the writing of the content fails
    /// - Returns: absolute path where the file is located
    @discardableResult
    func write(at directory: Path, alternativeFileName: String? = nil) throws -> Path {
        let absolutePath = directory + (alternativeFileName ?? fileName)
        try absolutePath.write(render().indentationFormatted())
        return absolutePath
    }
}

/// A protocol for object swift files (object models of the client library
protocol ObjectSwiftFile: SwiftFile {}
/// ObjectSwiftFile extension
extension ObjectSwiftFile {
    /// File header including file comment, foundation import and the signature of object declaration
    func fileHeader(annotation: String = "") -> String {
        """
        \(fileComment)

        \(Import(.foundation).render())
        
        \(MARKComment(.model))
        \(annotation)\(kind.signature) \(typeNameString): Codable {
        """
    }
}

/// An object that renders the header comment of a `Swift` file generated by `ApodiniMigrator`
public struct FileHeaderComment: Renderable {
    /// Name of the file
    public let fileName: String
    
    public init(fileName: String) {
        self.fileName = fileName
    }
    
    /// Returns the content of the file header comment
    public func render() -> String {
        """
        //
        //  \(fileName)
        //
        //  Created by ApodiniMigrator on \(Date().string(.date))
        //  Copyright \u{00A9} \(Date().string(.year)) TUM LS1. All rights reserved.
        //
        """
    }
}

/// An object representing imports of a Swift file
struct Import: Renderable {
    /// Distinct framework cases that can be imported in `ApodiniMigrator`
    enum Frameworks: String {
        case foundation
        case combine
        case apodiniMigrator
        case apodiniMigratorClientSupport
        case xCTest
        
        /// String representation of the import
        var string: String {
            "import \(rawValue.upperFirst)"
        }
    }
    
    /// Set of to be imported frameworks
    private var frameworks: Set<Frameworks>
    
    /// Initializes `self` with `frameworks`
    init(_ frameworks: Frameworks...) {
        self.frameworks = Set(frameworks)
    }
    
    /// Inserts `framework`
    mutating func insert(_ framework: Frameworks) {
        frameworks.insert(framework)
    }
    
    /// String represeantion of `frameworks`
    /// One line per framwork, no empty lines in between
    func render() -> String {
        """
        \(frameworks.map { $0.string }.lineBreaked)
        """
    }
}
