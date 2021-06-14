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
    var configuration: EncoderConfiguration
    
    init(lhs: TypeInformation, rhs: TypeInformation, changes: ChangeContainer, configuration: EncoderConfiguration) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
        self.configuration = configuration
    }
    
    func compare() {
    }
}
