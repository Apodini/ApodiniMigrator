//
//  File.swift
//  
//
//  Created by Eldi Cano on 14.05.21.
//

import Foundation

import ApodiniMigrator

struct Test {
    
    func test() {
        struct User {
            let id: Int
            let name: String
        }
        
        let s = try! TypeInformation(type: User.self)
        
    }
}
