//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigratorCore

extension Endpoint: GRPCMethodRepresentable, GRPCMethodRenderable {
    var methodName: String {
        identifier(for: GRPCMethodName.self).rawValue
    }

    var serviceName: String {
        identifier(for: GRPCServiceName.self).rawValue
    }

    var unavailable: Bool {
        false
    }

    var sourceCodeComments: String? {
        nil
    }

    var streamingType: StreamingType {
        switch communicationalPattern {
        case .requestResponse:
            return .unary
        case .clientSideStream:
            return .clientStreaming
        case .serviceSideStream:
            return .serverStreaming
        case .bidirectionalStream:
            return .bidirectionalStreaming
        }
    }

    var inputMessageName: String {
        // TODO packageName!
        handlerName.buildName() + "___INPUT" // TODO magic constant from ApodiniGRPC
    }

    var outputMessageName: String {
        // TODO packageName
        // TODO handle reference types
        response.typeName.buildName()
    }
}
