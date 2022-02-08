//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

enum OutputFiles: String, TestResource {
    // enum files
    case defaultStringEnum
    case defaultIntEnum
    case enumAddedCase
    case enumDeletedCase
    case enumRawValue
    case enumDeletedSelf
    case enumUnsupportedChange
    case enumMultipleChanges

    // object files
    case defaultObjectFile
    case objectAddedProperty
    case objectDeletedProperty
    case objectRenamedProperty
    case objectPropertyNecessityToRequiredChange
    case objectPropertyNecessityToOptionalChange
    case objectPropertyTypeChange
    case objectUnsupportedChange
    case objectDeletedChange
    case objectMultipleChange

    // auxiliary
    case modelsTestFile
    case aPIFile

    // endpoint files
    case defaultEndpointFile
    case endpointPathChange
    case endpointOperationChange
    case endpointAddParameterChange
    case endpointDeleteParameterChange
    case endpointDeleteContentParameterChange
    case endpointRenameParameterChange
    case endpointParameterNecessityToRequiredChange // swiftlint:disable:this identifier_name
    case endpointParameterKindAndPathChange
    case endpointParameterTypeChange
    case endpointResponseChange
    case endpointDeletedChange
    case endpointMultipleChanges
    case endpointWrappedContentParameter

    // grpc end2end
    case pbFileV1 = "QONECTIQ.pb.v1"
    case grpcFileV1 = "QONECTIQ.grpc.v1"
    case pbFileV2 = "QONECTIQ.pb.v2"
    case grpcFileV2 = "QONECTIQ.grpc.v2"

    var fileName: String {
        rawValue.upperFirst + ".swift"
    }
}
