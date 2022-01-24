//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct GRPCExporterConfiguration: ExporterConfiguration {
    public static var type: ApodiniExporterType {
        .grpc
    }

    public let packageName: String
    public let serviceName: String
    public let pathPrefix: String
    public let reflectionEnabled: Bool

    public init(packageName: String, serviceName: String, pathPrefix: String, reflectionEnabled: Bool) {
        self.packageName = packageName
        self.serviceName = serviceName
        self.pathPrefix = pathPrefix
        self.reflectionEnabled = reflectionEnabled
    }
}
