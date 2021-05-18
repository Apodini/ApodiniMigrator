import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(___PACKAGE_NAME___Tests.allTests),
    ]
}
#endif
