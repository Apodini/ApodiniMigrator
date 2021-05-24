//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

struct DocumentComparator: Comparator {
    let lhs: Document
    let rhs: Document
    var changes: ChangeContainer
    
    init(lhs: Document, rhs: Document, changes: ChangeContainer) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
    }
    
    func compare() {
        let metaDataComparator = MetaDataComparator(lhs: lhs.metaData, rhs: rhs.metaData, changes: changes)
        metaDataComparator.compare()
        let endpointsComparator = EndpointsComparator(lhs: lhs.endpoints, rhs: rhs.endpoints, changes: changes)
        endpointsComparator.compare()
    }
}
