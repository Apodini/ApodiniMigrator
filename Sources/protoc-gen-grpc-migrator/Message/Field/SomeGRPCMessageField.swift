//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftProtobufPluginLibrary
import SwiftProtobuf
import ApodiniTypeInformation

protocol SomeGRPCMessageField {
    var context: ProtoFileContext { get }

    var hasFieldPresence: Bool { get }

    var name: String { get }
    var privateName: String { get }
    var storedProperty: String { get }
    var propertyHasName: String { get }
    var funcClearName: String { get }

    var type: Google_Protobuf_FieldDescriptorProto.TypeEnum { get }

    var typeName: String { get }
    var storageType: String { get }
    var defaultValue: String { get }
    var traitsType: String { get }
    var protoGenericType: String { get }

    var sourceCodeComments: String? { get }

    var number: Int { get }

    var fieldMapNames: String { get }

    var isMap: Bool { get }
    var isPacked: Bool { get }
    var isRepeated: Bool { get }

    /// If present, this represents the update property name in the new web service version.
    var updatedName: String? { get }
    /// If true, it indicates that this property was removed in the latest version
    var unavailable: Bool { get }
    /// Records the script id of a optional fallbackValue if marked `unavailable`.
    var fallbackValue: Int? { get }
    var necessityUpdate: (from: Necessity, to: Necessity, necessityMigration: Int)? { get }
    var typeUpdate: (from: TypeInformation, to: TypeInformation, forwardMigration: Int, backwardMigration: Int)? { get }
}

extension SomeGRPCMessageField {
    var updatedName: String? {
        nil
    }

    var unavailable: Bool {
        false
    }

    var fallbackValue: Int? {
        nil
    }

    var necessityUpdate: (from: Necessity, to: Necessity, necessityMigration: Int)? {
        nil
    }

    var typeUpdate: (from: TypeInformation, to: TypeInformation, forwardMigration: Int, backwardMigration: Int)? {
        nil
    }
}