//
//  WebService.swift
//
//  Created by ApodiniMigrator on 26.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
public enum WebService {
    /// API call for Random at: rand
    static func getRandomInt(number: Int) -> ApodiniPublisher<Int> {
        Int.getRandomInt(number: number)
    }
    
    /// API call for PostHandler at: user/{userId}/post/{postId}
    static func getPost(postId: UUID, userId: Int) -> ApodiniPublisher<Post> {
        Post.getPost(postId: postId, userId: userId)
    }
    
    /// API call for TraditionalGreeter at: greet
    static func greetMe(age: Int, name: String?, surname: String) -> ApodiniPublisher<String> {
        String.greetMe(age: age, name: name, surname: surname)
    }
    
    /// API call for Text at: swift/5/3
    static func helloSwiftFiveDotThree() -> ApodiniPublisher<String> {
        String.helloSwiftFiveDotThree()
    }
    
    /// API call for Auction at: auction
    static func placeBid(bid: UInt) -> ApodiniPublisher<String> {
        String.placeBid(bid: bid)
    }
    
    /// API call for Text at: swift
    static func sayHelloToSwift() -> ApodiniPublisher<String> {
        String.sayHelloToSwift()
    }
    
    /// API call for Text at:
    static func sayHelloWorld() -> ApodiniPublisher<String> {
        String.sayHelloWorld()
    }
    
    /// API call for AuthenticatedUserHandler at: authenticated
    static func getAuthenticatedUser() -> ApodiniPublisher<User> {
        User.getAuthenticatedUser()
    }
    
    /// API call for UserHandler at: user/{userId}
    static func getUserById(userId: Int) -> ApodiniPublisher<User> {
        User.getUserById(userId: userId)
    }
}
