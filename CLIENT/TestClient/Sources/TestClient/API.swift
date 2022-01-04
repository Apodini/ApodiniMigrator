//
//  API.swift
//
//  Created by ApodiniMigrator on 14.11.21
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - API
public enum API {}

// MARK: - Endpoints
public extension API {
    /// API call for Greeter at:
    static func greeter(
        name: String,
        authorization: String? = nil,
        httpHeaders: HTTPHeaders = [:]
    ) -> ApodiniPublisher<Greeting> {
        Greeting.greeter(
            name: name,
            authorization: authorization,
            httpHeaders: httpHeaders
        )
    }
}
