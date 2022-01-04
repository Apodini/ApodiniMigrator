//
//  Created by ApodiniMigrator on 15.08.20
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
public extension Bool {
    /// API call for someHandler at: test
    static func id(
        wrappedContentParameter: SomeWrappedContent,
        authorization: String? = nil,
        httpHeaders: HTTPHeaders = [:]
    ) -> ApodiniPublisher<Bool> {
        var headers = httpHeaders
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        
        let handler = Handler<Bool>(
            path: "test",
            httpMethod: .post,
            parameters: [:],
            headers: headers,
            content: NetworkingService.encode(wrappedContentParameter),
            authorization: authorization,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
}
