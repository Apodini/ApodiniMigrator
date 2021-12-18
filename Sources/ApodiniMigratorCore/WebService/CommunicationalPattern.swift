//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Defines the communicational pattern of a given endpoint.
public enum CommunicationalPattern: String, CaseIterable, Value {
    /// **One** client message followed by **one** service message
    case requestResponse
    /// **Any amount** of client messages followed by **one** service message
    case clientSideStream
    /// **One** client message followed by **any amount** of service messages
    case serviceSideStream
    /// **Any amount** of client messages and **any amount** of service messages in an **undefined order**
    case bidirectionalStream
}
