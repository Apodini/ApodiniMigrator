//
//  File.swift
//  
//
//  Created by Eldi Cano on 03.06.21.
//

import Foundation

/// A result builder protocol out of an input
public protocol Builder {
    /// Input
    associatedtype Input
    
    /// Result of `build() throws`
    associatedtype Result
    
    /// Input of the builder
    var input: Input { get }
    
    /// Initializer of the instance
    init(_ input: Input)
    
    /// Builds and returns the result
    func build() throws -> Result
}
