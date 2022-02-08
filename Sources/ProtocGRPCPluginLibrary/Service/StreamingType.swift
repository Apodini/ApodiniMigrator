//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

/*
 * Copyright 2018, gRPC Authors All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import SwiftProtobufPluginLibrary
import ApodiniMigratorCore

internal enum StreamingType {
    case unary
    case clientStreaming
    case serverStreaming
    case bidirectionalStreaming

    var isStreamingResponse: Bool {
        switch self {
        case .serverStreaming, .bidirectionalStreaming:
            return true
        default:
            return false
        }
    }

    var isStreamingRequest: Bool {
        switch self {
        case .clientStreaming, .bidirectionalStreaming:
            return true
        default:
            return false
        }
    }
}

extension StreamingType {
    var grpcCallTypeString: String {
        switch self {
        case .unary:
            return "AsyncUnaryCall"
        case .clientStreaming:
            return "AsyncClientStreamingCall"
        case .serverStreaming:
            return "AsyncServerStreamingCall"
        case .bidirectionalStreaming:
            return "AsyncBidirectionalStreamingCall"
        }
    }

    var requestParameterName: String {
        self.isStreamingRequest
            ? "requests"
            : "request"
    }
}

extension StreamingType {
    init(from pattern: CommunicationPattern) {
        switch pattern {
        case .requestResponse:
            self = .unary
        case .clientSideStream:
            self = .clientStreaming
        case .serviceSideStream:
            self = .serverStreaming
        case .bidirectionalStream:
            self = .bidirectionalStreaming
        }
    }
}
