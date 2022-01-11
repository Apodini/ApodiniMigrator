//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import SwiftProtobuf
import SwiftProtobufPluginLibrary

protocol FieldDescriptorLike {
    var protoType: Google_Protobuf_FieldDescriptorProto.TypeEnum { get }

    var label: Google_Protobuf_FieldDescriptorProto.Label { get }

    var explicitDefaultValue: String? { get }

    var isMap: Bool { get }
    var hasPresence: Bool { get }

    /// The type of the property is a message and represents a map
    /// this property must return the according map description.
    /// Otherwise return nil.
    var mapKeyAndValueDescription: (key: FieldDescriptorLike, value: FieldDescriptorLike)? { get }

    /// This method is used to derive the `SwiftProtobufNamer/fullName(message:)`
    /// or `SwiftProtobufNamer/fullName(enum:)` names. Return nil if it is applied to
    /// a non `.group`, `.message` or `.enum` type.
    func retrieveFullName(namer: SwiftProtobufNamer) -> String?

    /// This method is used to derive the `SwiftProtobufNamer/dottedRelativeName(enumValue:)`
    /// of the default value of a enum type. Return nil if this is applicable to a non `.enum` type.
    func enumDefaultValueDottedRelativeName(namer: SwiftProtobufNamer, for caseValue: String?) -> String?
}
