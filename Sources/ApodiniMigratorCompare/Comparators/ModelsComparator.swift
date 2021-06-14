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
    let changes: ChangeContainer
    var configuration: EncoderConfiguration
    
    func compare() {
    }
}
