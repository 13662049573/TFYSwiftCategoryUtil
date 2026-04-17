import XCTest
@testable import TFYSwiftCategoryUtil

final class StringChainTests: XCTestCase {
    func testIncludesEmojiAndNumericParsing() {
        XCTAssertTrue("hello😀".tfy.includesEmoji())
        XCTAssertFalse("plain-text".tfy.includesEmoji())
        
        XCTAssertEqual("42".tfy.toInt(), 42)
        XCTAssertEqual("3.14".tfy.toDouble(), 3.14, accuracy: 0.0001)
    }
}
