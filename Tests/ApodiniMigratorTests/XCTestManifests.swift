import XCTest

#if !canImport(ObjectiveC)
/// :nodoc:
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(ApodiniMigratorTests.allTests)
    ]
}
#endif
