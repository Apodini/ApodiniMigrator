//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniTypeInformation
import MigratorAPI

struct EnumExtensions: RenderableBuilder {
    let `enum`: TypeInformation
    let rawValueType: TypeInformation
    var typeName: String {
        `enum`.typeString
    }
    
    init(_ enum: TypeInformation, rawValueType: TypeInformation) {
        self.enum = `enum`
        self.rawValueType = rawValueType
    }

    var fileContent: String {
        MARKComment("CustomStringConvertible")
        "\(Kind.extension.rawValue) \(typeName): CustomStringConvertible {"
        Indent {
            "\(GenericComment(comment: "/// Textual representation"))"
            "public var description: String {"
            Indent {
                "rawValue.description"
            }
            "}"
        }
        "}"

        ""

        MARKComment("LosslessStringConvertible")
        "\(Kind.extension.rawValue) \(typeName): LosslessStringConvertible {"
        Indent {
            "\(GenericComment(comment: "/// Instantiates an instance of the conforming type from a string representation."))"
            "public init?(_ description: String) {"
            Indent {
              if rawValueType == .scalar(.string) {
                  "self.init(rawValue: description)"
              } else {
                  "if let rawValue = RawValue(description) {"
                  Indent {
                      "self.init(rawValue: rawValue)"
                  }
                  "} else {"
                  Indent {
                      "return nil"
                  }
                  "}"
              }
            }
            "}"
        }
        "}"
    }
}
