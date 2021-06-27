//
//  RuntimeBuilder.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 27.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
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
