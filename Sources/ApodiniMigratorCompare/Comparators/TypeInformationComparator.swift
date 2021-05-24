//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

struct TypeInformationComparator: Comparator {
    let lhs: TypeInformation
    let rhs: TypeInformation
    var changes: ChangeContainer
    
    init(lhs: TypeInformation, rhs: TypeInformation, changes: ChangeContainer) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
    }
    
    func compare() {
        
    }
}
