//
//  Value.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// A protocol that requires conformance to `Codable` and `Hashable` (also `Equatable`),
/// that most of the objects in `ApodiniMigrator` conform to
public protocol Value: Codable, Hashable {}
