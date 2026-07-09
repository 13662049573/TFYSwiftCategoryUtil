import XCTest
@testable import TFYSwiftCategoryUtil

final class StringChainTests: XCTestCase {
    func testIncludesEmojiAndNumericParsing() {
        XCTAssertTrue("hello😀".tfy.includesEmoji())
        XCTAssertFalse("plain-text".tfy.includesEmoji())
        
        XCTAssertEqual("42".tfy.toInt(), 42)
        XCTAssertEqual("3.14".tfy.toDouble(), 3.14, accuracy: 0.0001)
    }

    func testSubstringHelpersClampOutOfBoundsIndexes() {
        XCTAssertEqual("abcdef".subString(to: 2), "ab")
        XCTAssertEqual("abcdef".subString(to: 100), "abcdef")
        XCTAssertEqual("abcdef".subString(to: -2), "")

        XCTAssertEqual("abcdef".subString(from: 2), "cdef")
        XCTAssertEqual("abcdef".subString(from: 100), "")
        XCTAssertEqual("abcdef".subString(from: -2), "abcdef")
    }
}
