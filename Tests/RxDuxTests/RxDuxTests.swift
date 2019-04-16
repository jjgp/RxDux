import XCTest
@testable import RxDux

final class RxDuxTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RxDux().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
