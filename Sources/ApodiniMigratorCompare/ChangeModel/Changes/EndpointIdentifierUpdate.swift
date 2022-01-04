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
public typealias EndpointIdentifierChange = Change<AnyEndpointIdentifier>

extension AnyEndpointIdentifier: ChangeableElement {
    public typealias Update = EndpointIdentifierUpdateChange
}

public struct EndpointIdentifierUpdateChange: Codable, Equatable {
    public let from: AnyEndpointIdentifier
    public let to: AnyEndpointIdentifier
}
