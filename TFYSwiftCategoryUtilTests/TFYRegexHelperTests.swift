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
}
