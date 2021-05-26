//
//  WebService.swift
//
//  Created by ApodiniMigrator on 26.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
public enum WebService {
    /// API call for Random at: /v1/rand
    static func getRandomInt(number: Int) -> ApodiniPublisher<Int> {
        Int.getRandomInt(number: number)
    }
    
    /// API call for PostHandler at: /v1/user/{userId}/post/{postId}
    static func getPost(postId: UUID, userId: Int) -> ApodiniPublisher<Post> {
        Post.getPost(postId: postId, userId: userId)
    }
    
    /// API call for TraditionalGreeter at: /v1/greet
    static func greetMe(age: Int, name: String?, surname: String) -> ApodiniPublisher<String> {
        String.greetMe(age: age, name: name, surname: surname)
    }
    
    /// API call for Text at: /v1/swift/5/3
    static func helloSwiftFiveDotThree() -> ApodiniPublisher<String> {
        String.helloSwiftFiveDotThree()
    }
    
    /// API call for Auction at: /v1/auction
    static func placeBid(bid: UInt) -> ApodiniPublisher<String> {
        String.placeBid(bid: bid)
    }
    
    /// API call for Text at: /v1/swift
    static func sayHelloToSwift() -> ApodiniPublisher<String> {
        String.sayHelloToSwift()
    }
    
    /// API call for Text at: /v1
    static func sayHelloWorld() -> ApodiniPublisher<String> {
        String.sayHelloWorld()
    }
    
    /// API call for AuthenticatedUserHandler at: /v1/authenticated
    static func getAuthenticatedUser() -> ApodiniPublisher<User> {
        User.getAuthenticatedUser()
    }
    
    /// API call for UserHandler at: /v1/user/{userId}
    static func getUserById(userId: Int) -> ApodiniPublisher<User> {
        User.getUserById(userId: userId)
    }
}
