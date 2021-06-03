//
//  File.swift
//  
//
//  Created by Eldi Cano on 03.06.21.
//

import Foundation

public protocol Builder {
    associatedtype Input
    associatedtype Result
    
    var input: Input { get }
    
    init(_ input: Input)
    
    func build() throws -> Result
}

public protocol TypeInformationBuilder: Builder where Input == Any.Type, Result == TypeInformation {}

public struct RuntimeBuilder: TypeInformationBuilder {
    public let input: Any.Type
    
    public init(_ input: Any.Type) {
        self.input = input
    }
    
    public func build() throws -> TypeInformation {
        try TypeInformation(type: input)
    }
}

public struct JSONEncoderBuilder: TypeInformationBuilder {
    public let input: Any.Type
    
    public init(_ input: Any.Type) {
        self.input = input
    }
    
    public func build() throws -> TypeInformation {
        try TypeInformation(type: input)
    }
}

public extension TypeInformation {
    
    static func typeInformation<B: TypeInformationBuilder>(
        of type: Any.Type,
        with builderType: B.Type
    ) throws -> TypeInformation {
        try builderType.init(type).build()
    }
}
