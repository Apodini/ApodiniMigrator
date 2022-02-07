//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

enum ModelSearchResult {
    case `enum`(_ enum: GRPCEnum)
    case message(_ message: GRPCMessage)
}

extension ModelSearchResult {
    func handleIdChange(change: ModelChange.IdentifierChange) {
        switch self {
        case let .enum(grpcEnum):
            guard let protoEnum = grpcEnum.tryTyped(for: ProtoGRPCEnum.self) else {
                fatalError("Renamed model isn't a native proto model. For change: \(change)!")
            }
            protoEnum.applyIdChange(change)
        case let .message(message):
            guard let protoMessage = message.tryTyped(for: ProtoGRPCMessage.self) else {
                fatalError("Renamed model isn't a native proto model. For change: \(change)!")
            }
            protoMessage.applyIdChange(change)
        }
    }

    func handleUpdateChange(change: ModelChange.UpdateChange) {
        switch self {
        case let .enum(grpcEnum):
            guard let protoEnum = grpcEnum.tryTyped(for: ProtoGRPCEnum.self) else {
                fatalError("Updated model isn't a native proto model. For update: \(change)!")
            }
            protoEnum.applyUpdateChange(change)
        case let .message(message):
            if let protoMessage = message.tryTyped(for: ProtoGRPCMessage.self) {
                protoMessage.applyUpdateChange(change)
            } else if let apodiniMessage = message.tryTyped(for: ApodiniGRPCMessage.self) {
                apodiniMessage.applyUpdateChange(change)
            } else {
                fatalError("Updated model isn't a updatable model. For update: \(change)!")
            }
        }
    }

    func handleRemovalChange(change: ModelChange.RemovalChange) {
        switch self {
        case let .enum(grpcEnum):
            guard let protoEnum = grpcEnum.tryTyped(for: ProtoGRPCEnum.self) else {
                fatalError("Removed model isn't a native proto model. For removal: \(change)!")
            }
            protoEnum.applyRemovalChange(change)
        case let .message(message):
            guard let protoMessage = message.tryTyped(for: ProtoGRPCMessage.self) else {
                fatalError("Removed model isn't a native proto model. For removal: \(change)!")
            }
            protoMessage.applyRemovalChange(change)
        }
    }
}
