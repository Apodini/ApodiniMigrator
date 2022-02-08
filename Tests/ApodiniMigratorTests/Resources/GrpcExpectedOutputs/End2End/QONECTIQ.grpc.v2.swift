//
//  Created by ApodiniMigrator on 15.08.20
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation
import NIO
import GRPC
import SwiftProtobuf

public struct QONECTIQAsyncClient: GRPCClient {
    public var serviceName: String {
        "QONECTIQ2.QONECTIQ"
    }
    
    public var channel: GRPCChannel
    public var defaultCallOptions: CallOptions
    public init(
        channel: GRPCChannel,
        defaultCallOptions: CallOptions = CallOptions()
    ) {
        self.channel = channel
        self.defaultCallOptions = defaultCallOptions
    }
}

extension QONECTIQAsyncClient {
    
    /// APODINI-identifier: addReviewToEvent
    /// APODINI-handlerName: QONECTIQV1.AddReviewHandler
    public func addReviewHandler(
        _ request: QONECTIQ_AddReviewHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_Review {
        let migrateResponse: (QONECTIQ_ReviewForm) throws -> QONECTIQ_Review = {
            try QONECTIQ_Review.from($0, script: 28)
        }
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/AddReviewHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_ReviewForm.self
        )
        return try migrateResponse(result)
    }
    
    /// APODINI-identifier: createCategory
    /// APODINI-handlerName: QONECTIQV1.CreateCategoryHandler
    public func createCategoryHandler(
        _ request: QONECTIQ_EventCategory,
        callOptions: CallOptions? = nil
    ) async throws -> SwiftProtobuf.Google_Protobuf_Empty {
        let request = try QONECTIQ_EventCategoryMediator.from(request, script: 29)
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/CreateCategoryHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: SwiftProtobuf.Google_Protobuf_Empty.self
        )
        return result
    }
    
    /// APODINI-identifier: createEvent
    /// APODINI-handlerName: QONECTIQV1.CreateEventHandler
    public func createEventHandler(
        _ request: QONECTIQ_Event,
        callOptions: CallOptions? = nil
    ) async throws -> SwiftProtobuf.Google_Protobuf_Empty {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/CreateEventHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: SwiftProtobuf.Google_Protobuf_Empty.self
        )
        return result
    }
    
    /// APODINI-identifier: register
    /// APODINI-handlerName: QONECTIQV1.UserRegisterFormHandler
    public func createUserRegisterFormHandler(
        _ request: QONECTIQ_UserRegisterForm,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_User {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/CreateUserRegisterFormHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_User.self
        )
        return result
    }
    
    /// APODINI-identifier: deleteEventWithID
    /// APODINI-handlerName: QONECTIQV1.DeleteEventHandler
    public func deleteEventHandler(
        _ request: QONECTIQ_DeleteEventHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_Event {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/DeleteEventHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_Event.self
        )
        return result
    }
    
    /// APODINI-identifier: deleteUserWithID
    /// APODINI-handlerName: QONECTIQV1.DeleteUserHandler
    public func deleteUserHandler(
        _ request: QONECTIQ_DeleteUserHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> SwiftProtobuf.Google_Protobuf_Empty {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/DeleteUserHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: SwiftProtobuf.Google_Protobuf_Empty.self
        )
        return result
    }
    
    /// APODINI-identifier: getAllUsers
    /// APODINI-handlerName: QONECTIQV1.GetAllUsersHandler
    public func getAllUsersHandler(
        _ request: SwiftProtobuf.Google_Protobuf_Empty,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_GetAllUsersHandlerResponse {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetAllUsersHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_GetAllUsersHandlerResponse.self
        )
        return result
    }
    
    /// APODINI-identifier: getAllCategories
    /// APODINI-handlerName: QONECTIQV1.GetCategoriesHandler
    public func getCategoriesHandler(
        _ request: SwiftProtobuf.Google_Protobuf_Empty,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_GetCategoriesHandlerResponse {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetCategoriesHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_GetCategoriesHandlerResponse.self
        )
        return result
    }
    
    /// APODINI-identifier: getEventsOfCategory
    /// APODINI-handlerName: QONECTIQV1.CategoryEventsHandler
    public func getCategoryEventsHandler(
        _ request: QONECTIQ_CategoryEventsHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_CategoryEventsHandlerResponse {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/CreateCategoryEventsHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_CategoryEventsHandlerResponse.self
        )
        return result
    }
    
    /// APODINI-identifier: getCategoryWithID
    /// APODINI-handlerName: QONECTIQV1.GetCategoryHandler
    public func getCategoryHandler(
        _ request: QONECTIQ_GetCategoryHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_EventCategory {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetCategoryHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_EventCategory.self
        )
        return result
    }
    
    /// APODINI-identifier: getEventWithID
    /// APODINI-handlerName: QONECTIQV1.GetEventHandler
    public func getEventHandler(
        _ request: QONECTIQ_GetEventHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_Event {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetEventHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_Event.self
        )
        return result
    }
    
    /// APODINI-identifier: getAllEvents
    /// APODINI-handlerName: QONECTIQV1.GetEventsHandler
    public func getEventsHandler(
        _ request: SwiftProtobuf.Google_Protobuf_Empty,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_GetEventsHandlerResponse {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetEventsHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_GetEventsHandlerResponse.self
        )
        return result
    }
    
    /// APODINI-identifier: usersOfExperience
    /// APODINI-handlerName: QONECTIQV1.ExperienceUsersHandler
    @available(*, deprecated, message: "This method is not available in the new version anymore. Calling this method will fail!")
    public func getExperienceUsersHandler(
        _ request: QONECTIQ_ExperienceUsersHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_ExperienceUsersHandlerResponse {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetExperienceUsersHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_ExperienceUsersHandlerResponse.self
        )
        return result
    }
    
    /// APODINI-identifier: getCategoriesOfGroup
    /// APODINI-handlerName: QONECTIQV1.GroupCategoriesHandler
    public func getGroupCategoriesHandler(
        _ request: QONECTIQ_GroupCategoriesHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_GroupCategoriesHandlerResponse {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetGroupCategoriesHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_GroupCategoriesHandlerResponse.self
        )
        return result
    }
    
    /// APODINI-identifier: getHomeFeedForUserWithID
    /// APODINI-handlerName: QONECTIQV1.HomeFeedHandler
    public func getHomeFeedHandler(
        _ request: QONECTIQ_HomeFeedHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_HomeFeed {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetHomeFeedHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_HomeFeed.self
        )
        return result
    }
    
    /// APODINI-identifier: getParticipantsOfEventWithID
    /// APODINI-handlerName: QONECTIQV1.GetParticipantsOfEventHandler
    public func getParticipantsOfEventHandler(
        _ request: QONECTIQ_GetParticipantsOfEventHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_GetParticipantsOfEventHandlerResponse {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetParticipantsOfEventHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_GetParticipantsOfEventHandlerResponse.self
        )
        return result
    }
    
    /// APODINI-identifier: getReviewsOfEventWithID
    /// APODINI-handlerName: QONECTIQV1.ReviewsHandler
    public func getReviewsHandler(
        _ request: QONECTIQ_ReviewsHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_ReviewsHandlerResponse {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetReviewsHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_ReviewsHandlerResponse.self
        )
        return result
    }
    
    public func getReviewsOfUserHandler(
        _ request: QONECTIQ_ReviewsOfUserHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_ReviewsOfUserHandlerResponse {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetReviewsOfUserHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_ReviewsOfUserHandlerResponse.self
        )
        return result
    }
    
    public func getSearchEventsHandler(
        _ request: QONECTIQ_SearchEventsHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_SearchEventsHandlerResponse {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetSearchEventsHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_SearchEventsHandlerResponse.self
        )
        return result
    }
    
    public func getStatisticsHandler(
        _ request: QONECTIQ_StatisticsHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_UserStatistic {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetStatisticsHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_UserStatistic.self
        )
        return result
    }
    
    /// APODINI-identifier: getUserWithID
    /// APODINI-handlerName: QONECTIQV1.GetUserHandler
    public func getUserHandler(
        _ request: QONECTIQ_GetUserHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_User {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetUserHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_User.self
        )
        return result
    }
    
    /// APODINI-identifier: login
    /// APODINI-handlerName: QONECTIQV1.UserLoginHandler
    public func getUserLoginHandler(
        _ request: QONECTIQ_UserLogin,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_User {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/GetUserLoginHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_User.self
        )
        return result
    }
    
    /// APODINI-identifier: updateEventWithID
    /// APODINI-handlerName: QONECTIQV1.UpdateEventHandler
    public func updateEventHandler(
        _ request: QONECTIQ_UpdateEventHandlerInput,
        callOptions: CallOptions? = nil
    ) async throws -> QONECTIQ_Event {
        let result = try await performAsyncUnaryCall(
            path: "/QONECTIQ2.QONECTIQ/UpdateEventHandler",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            responseType: QONECTIQ_Event.self
        )
        return result
    }
}