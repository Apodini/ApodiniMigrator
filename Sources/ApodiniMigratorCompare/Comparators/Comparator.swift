//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation


protocol Comparator {
    associatedtype Element: Value
    
    var lhs: Element { get }
    var rhs: Element { get }
    
    var changes: ChangeContainer { get }
    
    var configuration: EncoderConfiguration { get }
    
    func compare()
}
