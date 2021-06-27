//
//  RuntimeBuilder.swift
//  
//
//  Created by Eldi Cano on 03.06.21.
//

import Foundation

public struct RuntimeBuilder: TypeInformationBuilder {
    public let input: Any.Type
    
    public init(_ input: Any.Type) {
        self.input = input
    }
    
    public func build() throws -> TypeInformation {
        if let primitiveType = PrimitiveType(input) {
            return .scalar(primitiveType)
        }
        
        let typeInfo = try info(of: input)
        
        if let primitive = try typeInfo.cardinality.primitive() {
            return primitive
        }
        
        return try TypeInformation(type: input) // uses the current approach
    }
}
