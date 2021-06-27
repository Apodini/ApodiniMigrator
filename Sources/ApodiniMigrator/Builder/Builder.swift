//
//  Builder.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 27.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
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
