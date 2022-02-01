//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// ``Change`` type which is related to an `EndpointIdentifier`.
/// `.update` changes are encoded as `EndpointIdentifierUpdateChange`.
public typealias ElementIdentifierChange = Change<AnyElementIdentifier>

extension AnyElementIdentifier: ChangeableElement {
    public typealias Update = ElementIdentifierUpdateChange
}

public struct ElementIdentifierUpdateChange: Codable, Equatable {
    public let from: AnyElementIdentifier
    public let to: AnyElementIdentifier
}
