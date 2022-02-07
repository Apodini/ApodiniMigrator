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

protocol SomeGRPCMessageField: AnyObject {
    var context: ProtoFileContext { get }
    var migration: MigrationContext { get }

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

    var number: Int { get set }

    var fieldMapNames: String { get }

    var isMap: Bool { get }
    var isPacked: Bool { get }
    var isRepeated: Bool { get }

    /// If present, this represents the update property name in the new web service version.
    var updatedName: String? { get set }
    /// If true, it indicates that this property was removed in the latest version
    var unavailable: Bool { get set }
    /// Records the script id of a optional fallbackValue if marked `unavailable`.
    var fallbackValue: Int? { get set }
    var necessityUpdate: (from: Necessity, to: Necessity, necessityMigration: Int)? { get set }
    var typeUpdate: (from: TypeInformation, to: TypeInformation, forwardMigration: Int, backwardMigration: Int)? { get set }
    /// This change is derived from a change of the `GRPCFieldType` TypeInformationIdentifier.
    /// We track this only for informational purposes to check if our `typeUpdate` is consistent with what the server expects!
    var protoFieldTypeUpdate: Google_Protobuf_FieldDescriptorProto.TypeEnum? { get set }
}
