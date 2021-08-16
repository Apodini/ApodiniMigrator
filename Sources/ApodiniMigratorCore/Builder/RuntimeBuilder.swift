//
//  RuntimeBuilder.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

public struct RuntimeBuilder: TypeInformationBuilder {
    public let input: Any.Type
    
    public init(_ input: Any.Type) {
        self.input = input
    }
    
    public func build() throws -> TypeInformation {
        try TypeInformation(type: input) // uses the current approach
    }
}
