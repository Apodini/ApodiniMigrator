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
    
    init(lhs: Document, rhs: Document, changes: inout ChangeContainer) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
    }
    
    mutating func compare() {
        var metaDataComparator = MetaDataComparator(lhs: lhs.metaData, rhs: rhs.metaData, changes: &changes)
        metaDataComparator.compare()
        var endpointsComparator = EndpointsComparator(lhs: lhs.endpoints, rhs: rhs.endpoints, changes: &changes)
        endpointsComparator.compare()
    }
}
