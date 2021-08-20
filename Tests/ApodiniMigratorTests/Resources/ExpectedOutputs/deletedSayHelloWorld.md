/// API call for TestHandler at: hello
@available(*, deprecated, message: "This endpoint is not available in the new version anymore. Calling this method results in a failing promise!")
static func sayHelloWorld(
    authorization: String? = nil,
    httpHeaders: HTTPHeaders = [:]
) -> ApodiniPublisher<String> {
    Future { $0(.failure(ApodiniError.deletedEndpoint())) }.eraseToAnyPublisher()
}
