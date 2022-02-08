//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest
@testable import ApodiniMigratorExporterSupport

final class GRPCExporterConfigurationTests: ApodiniMigratorXCTestCase {
    func testEqualConfig() {
        var storage1 = ElementIdentifierStorage()
        storage1.add(identifier: GRPCName("test"))
        storage1.add(identifier: GRPCNumber(number: 2))
        storage1.add(identifier: GRPCFieldType(type: 11))

        var storage2 = ElementIdentifierStorage()
        storage2.add(identifier: GRPCName("test2"))
        storage2.add(identifier: GRPCNumber(number: 3))
        storage2.add(identifier: GRPCFieldType(type: 11))

        var storage3 = ElementIdentifierStorage()
        storage3.add(identifier: GRPCName("test3"))
        storage3.add(identifier: GRPCNumber(number: 4))
        storage3.add(identifier: GRPCFieldType(type: 11))

        let identifiersOfSynthesizedTypes: [String: EndpointSynthesizedTypes] = [
            "HelloWorld.Text": EndpointSynthesizedTypes(inputIdentifiers: TypeInformationIdentifiers(
                identifiers: storage1,
                childrenIdentifiers: ["name": storage2, "size": storage3]
            )),
            "HelloWorld.ExampleHandler": EndpointSynthesizedTypes(inputIdentifiers: TypeInformationIdentifiers(
                identifiers: storage3,
                childrenIdentifiers: ["id": storage1, "type": storage2]
            ))
        ]

        let configuration1 = GRPCExporterConfiguration(
            packageName: "HelloWorld",
            serviceName: "Earth",
            pathPrefix: "__apodini",
            reflectionEnabled: true,
            identifiersOfSynthesizedTypes: identifiersOfSynthesizedTypes
        )

        let configuration2 = configuration1

        XCTAssertEqual(configuration1, configuration2)
    }
}
