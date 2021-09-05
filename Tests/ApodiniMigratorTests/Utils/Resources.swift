//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

extension Resource {
    var bundle: Bundle { .module }
}

enum Documents: String, Resource {
    case v1 = "api_qonectiq1.0.0"
    case v2 = "api_qonectiq2.0.0"
    case migrationGuide = "migration_guide"
    
    var fileExtension: FileExtension { .json }
    
    var name: String { rawValue }
}

enum OutputFiles: String, Resource {
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
    
    var fileExtension: FileExtension { .markdown }
    
    var name: String { rawValue.upperFirst }
}
