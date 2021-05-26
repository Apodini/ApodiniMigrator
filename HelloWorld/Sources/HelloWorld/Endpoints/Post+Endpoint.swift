//
//  Post+Endpoint.swift
//
//  Created by ApodiniMigrator on 26.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
extension Post {
    // MARK: - getPost
    /// API call for PostHandler at: /v1/user/{userId}/post/{postId}
    static func getPost(postId: UUID, userId: Int) -> ApodiniPublisher<Post> {
        var headers: HTTPHeaders = [:]
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<Post>(
            path: "/v1/user/\(userId)/post/\(postId)",
            httpMethod: .get,
            parameters: [:],
            headers: headers,
            content: nil,
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
}
