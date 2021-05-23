//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation


protocol Comparator {
    associatedtype Element: Codable
    
    var lhs: Element { get }
    var rhs: Element { get }
    
    var changes: ChangeContainer { get }
    
    init(lhs: Element, rhs: Element, changes: inout ChangeContainer)
    
    mutating func compare()
}





struct ParameterComparator: Comparator { // todo needs .endpoint change element
    let lhs: Parameter
    let rhs: Parameter
    var changes: ChangeContainer
    
    init(lhs: Parameter, rhs: Parameter, changes: inout ChangeContainer) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
    }
    
    mutating func compare() {

    }
}
