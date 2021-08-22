//
//  TestResponse+Endpoint.swift
//
//  Created by ApodiniMigrator on 15.08.20
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Combine
import Foundation

// MARK: - Endpoints
public extension TestResponse {
    /// API call for TestHandler at: tests/{second}
    @available(*, deprecated, message: "This endpoint is not available in the new version anymore. Calling this method results in a failing promise!")
    static func testEndpoint(
        first: String,
        isDriving: String?,
        second: UUID,
        third: TestTypesCar,
        authorization: String? = nil,
        httpHeaders: HTTPHeaders = [:]
    ) -> ApodiniPublisher<TestResponse> {
        Future { $0(.failure(ApodiniError.deletedEndpoint())) }.eraseToAnyPublisher()
    }
}
