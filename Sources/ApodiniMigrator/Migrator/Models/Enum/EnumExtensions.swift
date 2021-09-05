//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniTypeInformation

struct EnumExtensions: Renderable {
    let `enum`: TypeInformation
    let rawValueType: TypeInformation
    var typeName: String {
        `enum`.typeString
    }
    
    init(_ enum: TypeInformation, rawValueType: TypeInformation) {
        self.enum = `enum`
        self.rawValueType = rawValueType
    }
    
    private func initBody() -> String {
        if rawValueType == .scalar(.string) {
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
