//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftProtobufPluginLibrary
import ApodiniMigrator

struct GRPCMethodApodiniAnnotations {
    // swiftlint:disable force_try
    private static let identifierRegex = try! NSRegularExpression(pattern: " APODINI-identifier: (.+)$")
    private static let handlerNameRegex = try! NSRegularExpression(pattern: " APODINI-handlerName: (.+)$")
    // swiftlint:enable force_try

    let apodiniIdentifier: String
    let handlerName: TypeName

    var deltaIdentifier: DeltaIdentifier {
        // see init of `Endpoint` TODO reduce code duplication
        var identifier = apodiniIdentifier
        // checks for "x.x.x." style Apodini identifiers!
        if !identifier.split(separator: ".").compactMap({ Int($0) }).isEmpty {
            identifier = handlerName.buildName()
        }

        return DeltaIdentifier(identifier)
    }

    init(of method: MethodDescriptor) {
        var identifier: String?
        var handlerName: String?

        let comments = method
            .protoSourceComments(commentPrefix: "")
            .components(separatedBy: "\n")

        for comment in comments {
            if let identifierValue = Self.match(on: comment, using: Self.identifierRegex) {
                identifier = identifierValue
            } else if let handlerNameValue = Self.match(on: comment, using: Self.handlerNameRegex) {
                handlerName = handlerNameValue
            }
        }

        guard let identifier = identifier else {
            fatalError("Proto comment section of method \(method.name) doesn't contain APODINI-identifier: \(comments)")
        }
        guard let handlerName = handlerName else {
            fatalError("Proto comment section of method \(method.name) doesn't contain APODINI-handlerName: \(comments)")
        }

        self.apodiniIdentifier = identifier
        self.handlerName = TypeName(rawValue: handlerName)
    }

    private static func match(on comment: String, using regex: NSRegularExpression) -> String? {
        let range = NSRange(comment.startIndex..., in: comment)
        guard let match = regex.firstMatch(in: comment, range: range) else {
            return nil
        }

        guard let value = comment.retrieveMatch(match: match, at: 1) else {
            return nil
        }

        return value
    }
}
