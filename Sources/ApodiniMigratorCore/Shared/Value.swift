//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A protocol that requires conformance to `Codable` and `Hashable` (also `Equatable`),
/// that most of the objects in `ApodiniMigrator` conform to
public protocol Value: Codable, Hashable {}

extension Array: Value where Element: Value {}
