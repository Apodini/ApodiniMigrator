//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

class GRPCMethodParameterCombination: ParameterCombination {
    let typeStore: TypesStore
    let lhsConfiguration: GRPCExporterConfiguration
    let rhsConfiguration: GRPCExporterConfiguration
    let migrationGuide: MigrationGuide

    init(typeStore: TypesStore, lhs: GRPCExporterConfiguration, rhs: GRPCExporterConfiguration, migrationGuide: MigrationGuide) {
        self.typeStore = typeStore
        self.lhsConfiguration = lhs
        self.rhsConfiguration = rhs
        self.migrationGuide = migrationGuide
    }

    func shouldBeMapped(parameter: Parameter) -> Bool {
        true // in grpc all parameters are combined!
    }

    func merge(parameters: [Parameter], of endpoint: Endpoint) -> Parameter? {
        precondition(!parameters.isEmpty, "Endpoints with zero parameters are handled inside `ApodiniGRPCMessage`: \(endpoint)")

        if parameters.count == 1,
           var first = parameters.first {
            first.dereference(in: typeStore)

            if (first.typeInformation.protoType == .message || first.typeInformation.protoType == .group)
                   && !first.typeInformation.isRepeated {
                // we (and ApodiniGRPC) don't care if the web service declared this property as optional.
                // grpc requires parameter to be required and it doesn't hurt to always send a optional parameter.
                return nil
            }
        }

        guard let identifiers = lhsConfiguration.identifiersOfSynthesizedTypes[endpoint.swiftTypeName]?.inputIdentifiers
            ?? rhsConfiguration.identifiersOfSynthesizedTypes[endpoint.updatedSwiftTypeName(considering: migrationGuide)]?.inputIdentifiers else {
            fatalError("When combining parameters for \(endpoint.handlerName.rawValue) failed to locate TypeInformationIdentifiers!")
        }

        // don't use the packageName, it might contain the update package name
        let grpcName = identifiers.identifiers.identifier(for: GRPCName.self)
            .parsed()

        let typeName = TypeName(
            definedIn: endpoint.handlerName.definedIn,
            rootType: TypeNameComponent(name: grpcName.typeName),
            nestedTypes: grpcName.nestedTypes.map { TypeNameComponent(name: $0) }
        )

        let typeInformation: TypeInformation = .object(
            name: typeName,
            properties: parameters.map { TypeProperty(from: $0) },
            context: Context() // context key for grpc identifiers are added later on
        )

        return Parameter(
            name: "request", // never used anywhere
            typeInformation: typeInformation,
            parameterType: .content, // not used in grpc
            isRequired: true // request is always required in grpc!
        )
    }
}
