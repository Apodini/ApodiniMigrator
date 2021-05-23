//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

//struct _EndpointsComparator: Encodable {
//    // MARK: Private Inner Types
//    private enum CodingKeys: String, CodingKey {
//        case changes
//    }
//    let lhs: Endpoint
//    let rhs: Endpoint
//    var changes: [Change]
//
//    var object: ChangeElement {
//        .endpoint(lhs.deltaIdentifier)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.unkeyedContainer()
//
//        for change in changes {
//            if let change = change as? AddChange {
//                try container.encode(change)
//            }
//
//            if let change = change as? StringChange {
//                try container.encode(change)
//            }
//
//            if let change = change as? DeleteChange {
//                try container.encode(change)
//            }
//        }
//    }
//
//    init(lhs: Endpoint, rhs: Endpoint) {
//        self.lhs = lhs
//        self.rhs = rhs
//        changes = []
//    }
//
//    mutating func compare() {
//        if lhs.absolutePath != rhs.absolutePath {
//            changes.append(StringChange(element: object, target: .path, from: lhs.absolutePath.description, to: rhs.absolutePath.description))
//        }
//
//        if lhs.operation != rhs.operation {
//            changes.append(StringChange(element: object, target: .operation, from: lhs.operation.rawValue, to: rhs.operation.rawValue))
//        }
//
//        compareQueryParameters()
//    }
//
//    mutating func compareQueryParameters() {
//        let lhs = self.lhs.queryParameters
//        let rhs = self.rhs.queryParameters
//
//        var processed: [DeltaIdentifier] = []
//
//        for lhsParam in lhs {
//            let id = lhsParam.deltaIdentifier
//            processed.append(id)
//
//            if let matched = rhs.first(where: { $0.matches(rhs: lhsParam) } ) {
//                /// todo create param comparator with changes
//            } else { /// todo perform relaxed equatable, pass inout processed
//                changes.append(DeleteChange(element: object, target: .queryParameter, deleted: .json(lhsParam.json), fallbackValue: .json(JSONStringBuilder.jsonString(lhsParam.typeInformation))))
//            }
//        }
//
//        let nonProcessed = rhs.filter { !processed.contains($0.deltaIdentifier) }
//
//        for non in nonProcessed {
//            let addchange = AddChange(element: object, target: .queryParameter, added: .json(non.json), defaultValue: .json(JSONStringBuilder.jsonString(non.typeInformation)))
//            changes.append(addchange)
//        }
//
//    }
//    
//    mutating func comparePathParameters() {
//        let lhs = self.lhs.pathParameters
//        let rhs = self.rhs.pathParameters
//    }
//    
//    mutating func compareContentParameter() {
//        let lhs = self.lhs.contentParameter
//        let rhs = self.rhs.contentParameter
//    }
//    
//    mutating func compareHeaderParameters() {
//        let lhs = self.lhs.headerParameters
//        let rhs = self.rhs.headerParameters
//    }
//}

