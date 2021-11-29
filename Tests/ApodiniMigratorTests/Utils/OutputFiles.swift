//
// Created by Andreas Bauer on 29.11.21.
//

import Foundation

enum OutputFiles: String, TestResource {
    // enum files
    case defaultStringEnum
    case defaultIntEnum
    case enumAddedCase
    case enumDeletedCase
    case enumRenamedCase
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
    case endpointParameterNecessityToRequiredChange
    case endpointParameterKindAndPathChange
    case endpointParameterTypeChange
    case endpointResponseChange
    case endpointDeletedChange
    case endpointMultipleChanges

    var fileName: String {
        rawValue.upperFirst + ".swift"
    }
}
