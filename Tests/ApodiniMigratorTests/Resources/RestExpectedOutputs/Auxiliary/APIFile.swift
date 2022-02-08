//
//  Created by ApodiniMigrator on 15.08.20
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - API
public enum API {}

// MARK: - Endpoints
public extension API {
    /// API call for TestHandler at: v1/hello
    static func sayHelloWorld(
        authorization: String? = nil,
        httpHeaders: HTTPHeaders = [:]
    ) -> ApodiniPublisher<String> {
        String.sayHelloWorld(
            authorization: authorization,
            httpHeaders: httpHeaders
        )
    }
}
