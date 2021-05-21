//
//  WebService.swift
//
//  Created by ApodiniMigrator on 21.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
public enum WebService {
    /// API call for Random at: /v1/rand
    static func getRandomInt(number: Int) -> ApodiniPublisher<IntResponse> {
        IntResponse.getRandomInt(number: number)
    }
    
    /// API call for PostHandler at: /v1/user/{userId}/post/{postId}
    static func getPost(postId: UUID, userId: Int) -> ApodiniPublisher<PostResponse> {
        PostResponse.getPost(postId: postId, userId: userId)
    }
    
    /// API call for TraditionalGreeter at: /v1/greet
    static func greetMe(age: Int, name: String?, surname: String) -> ApodiniPublisher<StringResponse> {
        StringResponse.greetMe(age: age, name: name, surname: surname)
    }
    
    /// API call for Text at: /v1/swift/5/3
    static func helloSwiftFiveDotThree() -> ApodiniPublisher<StringResponse> {
        StringResponse.helloSwiftFiveDotThree()
    }
    
    /// API call for Auction at: /v1/auction
    static func placeBid(bid: UInt) -> ApodiniPublisher<StringResponse> {
        StringResponse.placeBid(bid: bid)
    }
    
    /// API call for Text at: /v1/swift
    static func sayHelloToSwift() -> ApodiniPublisher<StringResponse> {
        StringResponse.sayHelloToSwift()
    }
    
    /// API call for Text at: /v1
    static func sayHelloWorld() -> ApodiniPublisher<StringResponse> {
        StringResponse.sayHelloWorld()
    }
    
    /// API call for AuthenticatedUserHandler at: /v1/authenticated
    static func getAuthenticatedUser() -> ApodiniPublisher<UserResponse> {
        UserResponse.getAuthenticatedUser()
    }
    
    /// API call for UserHandler at: /v1/user/{userId}
    static func getUserById(userId: Int) -> ApodiniPublisher<UserResponse> {
        UserResponse.getUserById(userId: userId)
    }
}
