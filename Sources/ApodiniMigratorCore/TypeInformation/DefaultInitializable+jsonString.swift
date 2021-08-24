//
//  DefaultInitializable+jsonString.swift
//  ApodiniMigratorCore
//
//  Created by Andreas Bauer on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import ApodiniTypeInformation

public extension DefaultInitializable {
    /// Json string of the default value
    static var jsonString: String { `default`.json }
}
