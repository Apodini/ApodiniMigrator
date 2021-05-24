//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

enum ChangeType: String, Value {
    case addition
    case deletion
    case rename
    case valueChange
    case parameterChange
    case typeChange
}

protocol Change: Codable {
    var element: ChangeElement { get }
    var target: ChangeTarget { get }
    var type: ChangeType { get }
}

extension Change {
    func typed<C: Change>(_ type: C.Type) -> C {
        guard let self = self as? C else {
            fatalError("Failed to cast change to \(C.self)")
        }
        return self
    }
}
