import Foundation

public enum GRPCNetworkingError: Error {
    case streamingTypeMigrationError(type: StreamingTypeMigrationErrorType)
}

/// Defines errors which might be thrown when a conversion from a
/// service side stream to service side response fails.
public enum StreamingTypeMigrationErrorType {
    /// Thrown if the first next() already fails to yield any response!
    case didNotReceiveAnyResponse
    /// Thrown if the server returned more than one response.
    /// We can't handle such migrations
    case didReceiveToManyResponses
}
