//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

private extension TypeInformation {
    var primitiveType: PrimitiveType {
        guard case let .scalar(primitiveType) = self else {
            fatalError("Tried to access primitive type of non-scalar values: \(self)")
        }
        return primitiveType
    }
}

struct GRPCMethodResponseWrapping: ResponseTypeWrapping {
    let lhsConfiguration: GRPCExporterConfiguration
    let rhsConfiguration: GRPCExporterConfiguration
    let migrationGuide: MigrationGuide

    init(lhs: GRPCExporterConfiguration, rhs: GRPCExporterConfiguration, migrationGuide: MigrationGuide) {
        self.lhsConfiguration = lhs
        self.rhsConfiguration = rhs
        self.migrationGuide = migrationGuide
    }

    func shouldBeWrapped(endpoint: Endpoint) -> Bool {
        let response = endpoint.response

        return response.isOptional
            || response.isRepeated
            || response.isEnum
            || (response.isScalar && response.primitiveType != .uuid && response.primitiveType != .url)
    }

    func wrap(responseType: TypeInformation, of endpoint: Endpoint) -> TypeInformation? {
        guard let identifiers = lhsConfiguration.identifiersOfSynthesizedTypes[endpoint.swiftTypeName]?.outputIdentifiers
            ?? rhsConfiguration.identifiersOfSynthesizedTypes[endpoint.updatedSwiftTypeName(considering: migrationGuide)]?.outputIdentifiers else {
            fatalError("When wrapping response type for \(endpoint.handlerName.rawValue) failed to locate TypeInformationIdentifiers!")
        }

        // don't use the packageName, it might contain the update package name
        let grpcName = identifiers.identifiers.identifier(for: GRPCName.self)
            .parsed()

        let typeName = TypeName(
            definedIn: endpoint.handlerName.definedIn,
            rootType: TypeNameComponent(name: grpcName.typeName),
            nestedTypes: grpcName.nestedTypes.map { TypeNameComponent(name: $0) }
        )

        return .object(
            name: typeName,
            properties: [
                TypeProperty(
                    name: "value",
                    type: endpoint.response,
                    annotation: nil,
                    context: Context() // context key for grpc identifiers are added later
                )
            ],
            context: Context() // context key for grpc identifiers are added later
        )
    }
}
