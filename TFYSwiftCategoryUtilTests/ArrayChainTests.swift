import XCTest
@testable import TFYSwiftCategoryUtil

final class ArrayChainTests: XCTestCase {
    func testHashableHasDuplicatesAndUniqueOrdered() {
        let values = [1, 2, 2, 3, 1]
        XCTAssertTrue(values.hasDuplicates)
        XCTAssertEqual(values.uniqueOrdered(), [1, 2, 3])
    }

    func testUniqueKeepsStableEncounterOrder() {
        let values = ["b", "a", "b", "c", "a"]
        XCTAssertEqual(values.unique(), ["b", "a", "c"])
    }
    
    func testNonHashableHasDuplicates() {
        let a = NSObject()
        let b = NSObject()
        let values = [a, b, a]
        XCTAssertTrue(values.hasDuplicates)
    }
}
