//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigratorExporterSupport

struct ParsedGRPCName: RawRepresentable {
    private(set) var packageName: String
    let nestedTypes: [String]
    let typeName: String

    var rawValue: String {
        "[\(packageName)].\((nestedTypes + [typeName]).joined(separator: "."))"
    }

    var containingType: ParsedGRPCName? {
        guard !nestedTypes.isEmpty else {
            return nil
        }

        var nestedTypes = nestedTypes
        let typeName = nestedTypes.removeLast()

        return ParsedGRPCName(packageName: packageName, nestedTypes: nestedTypes, typeName: typeName)
    }

    init(packageName: String, nestedTypes: [String], typeName: String) {
        self.packageName = packageName
        self.nestedTypes = nestedTypes
        self.typeName = typeName
    }

    init(rawValue: String) {
        var split = rawValue.components(separatedBy: ".")
        precondition(split.count >= 2, "Encountered malformed grpc name: \(rawValue)")

        var packageName = split.removeFirst()
        precondition(packageName.removeFirst() == "[", "Package name wasn't properly formatted: \(rawValue)")
        precondition(packageName.removeLast() == "]", "Package name wasn't properly formatted: \(rawValue)")

        let typeName = split.removeLast()

        self.packageName = packageName
        self.nestedTypes = split
        self.typeName = typeName
    }

    init(from: GRPCName, migration: MigrationContext? = nil) {
        self.init(rawValue: from.rawValue)

        if let migration = migration {
            self.packageName = migration.lhsExporterConfiguration.packageName
        }
    }
}

extension GRPCName {
    func parsed(migration: MigrationContext? = nil) -> ParsedGRPCName {
        ParsedGRPCName(from: self, migration: migration)
    }
}
