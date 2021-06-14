//
//  File.swift
//  
//
//  Created by Eldi Cano on 13.06.21.
//

import Foundation

struct ModelsComparator: Comparator {
    let lhs: [TypeInformation]
    let rhs: [TypeInformation]
    var changes: ChangeContainer
    var configuration: EncoderConfiguration
    
    func compare() {
        
    }
}
