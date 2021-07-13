//
//  File.swift
//  
//
//  Created by Eldi Cano on 13.07.21.
//

import Foundation

struct EnumExtensions: Renderable {
    let `enum`: TypeInformation
    let rawValueType: RawValueType
    var typeName: String {
        `enum`.typeString
    }
    
    init(_ enum: TypeInformation, rawValueType: RawValueType) {
        self.enum = `enum`
        self.rawValueType = rawValueType
    }
    
    private func initBody() -> String {
        if rawValueType == .string {
            return "self.init(rawValue: description)"
        }
        
        let body =
        """
        if let rawValue = RawValue(description) {
        self.init(rawValue: rawValue)
        } else {
        return nil
        }
        """
        return body
    }
    
    func render() -> String {
        let body =
            """
            \(MARKComment("CustomStringConvertible"))
            \(Kind.extension.rawValue) \(typeName): CustomStringConvertible {
            \(GenericComment(comment: "/// Textual representation"))
            public var description: String {
            rawValue.description
            }
            }
            
            \(MARKComment("LosslessStringConvertible"))
            \(Kind.extension.rawValue) \(typeName): LosslessStringConvertible {
            \(GenericComment(comment: "/// Instantiates an instance of the conforming type from a string representation."))
            public init?(_ description: String) {
            \(initBody())
            }
            }
            """
        return body
    }
}
