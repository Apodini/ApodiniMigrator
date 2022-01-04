//
//  Created by ApodiniMigrator on 06.12.21
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(RestLibraryTests.allTests)
    ]
}
#endif
