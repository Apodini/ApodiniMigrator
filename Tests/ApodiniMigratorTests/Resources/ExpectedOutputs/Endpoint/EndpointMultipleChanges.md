//
//  TestResponse+Endpoint.swift
//
//  Created by ApodiniMigrator on 15.08.20
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
public extension TestResponse {
    /// API call for TestHandler at: tests/{second}/{first}
    static func testEndpoint(
        first: String,
        isDriving: String?,
        newParameter: Bool = try! Bool.instance(from: 123),
        second: UUID,
        third: TestTypesCar,
        authorization: String? = nil,
        httpHeaders: HTTPHeaders = [:]
    ) -> ApodiniPublisher<TestResponse> {
        var parameters = Parameters()
        parameters.set(isDriving, forKey: "isDriving")
        parameters.set(newParameter, forKey: "newParameter")
        
        var headers = httpHeaders
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(404, message: "Not found")
        
        let handler = Handler<TestResponse>(
            path: "tests/\(second)/\(first)",
            httpMethod: .get,
            parameters: parameters,
            headers: headers,
            content: nil,
            authorization: authorization,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
}
