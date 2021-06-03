//
//  File.swift
//  
//
//  Created by Eldi Cano on 03.06.21.
//

import Foundation

public struct JSONEncoderBuilder: TypeInformationBuilder {
    public let input: Any.Type
    
    public init(_ input: Any.Type) {
        self.input = input
    }
    
    public func build() throws -> TypeInformation {
        try TypeInformation(type: input)
    }
}
