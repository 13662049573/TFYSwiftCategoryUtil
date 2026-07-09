import XCTest
@testable import TFYSwiftCategoryUtil

final class TFYRegexHelperTests: XCTestCase {
    func testMatchAndMatchRangesReturnExpectedResults() {
        XCTAssertTrue(TFYRegexHelper.match("hello123", pattern: "[a-z]+\\d+"))
        XCTAssertFalse(TFYRegexHelper.match("hello", pattern: "\\d+"))
        
        let ranges = TFYRegexHelper.matchRanges("ab12cd34", pattern: "\\d+")
        XCTAssertEqual(ranges.count, 2)
        XCTAssertEqual(ranges.first?.location, 2)
    }
    
    func testInvalidPatternFailsGracefully() {
        XCTAssertFalse(TFYRegexHelper.match("abc", pattern: "["))
        XCTAssertTrue(TFYRegexHelper.matchRanges("abc", pattern: "[").isEmpty)
    }

    func testCaptureGroupsAndReplacementHelpers() {
        let input = "name:Alice age:18"
        XCTAssertEqual(TFYRegexHelper.firstMatch(input, pattern: "name:\\w+"), "name:Alice")
        XCTAssertEqual(
            TFYRegexHelper.captureGroups(input, pattern: "name:(\\w+)\\s+age:(\\d+)"),
            ["Alice", "18"]
        )
        XCTAssertEqual(
            TFYRegexHelper.replacingMatches(in: input, pattern: "\\d+", with: "20"),
            "name:Alice age:20"
        )
    }
}
