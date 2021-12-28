//
//  XCTestManifests.swift
//
//  Created by ApodiniMigrator on 14.11.21
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(TestClientTests.allTests)
    ]
}
#endif
