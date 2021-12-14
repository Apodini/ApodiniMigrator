//
// Created by Andreas Bauer on 06.12.21.
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
