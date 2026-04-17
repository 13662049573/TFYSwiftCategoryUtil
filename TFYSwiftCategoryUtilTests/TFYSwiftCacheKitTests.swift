import XCTest
@testable import TFYSwiftCategoryUtil

final class TFYSwiftCacheKitTests: XCTestCase {
    private struct CacheModel: Codable, Equatable {
        let id: Int
        let name: String
    }
    
    func testSyncAPIsRejectMainThreadUsage() {
        let setResult = TFYSwiftCacheKit.shared.setCacheSync(CacheModel(id: 1, name: "main"), forKey: "main-thread-key")
        if case .failure = setResult {
            // expected
        } else {
            XCTFail("setCacheSync should reject main-thread usage")
        }
        
        let getResult = TFYSwiftCacheKit.shared.getCacheSync(CacheModel.self, forKey: "main-thread-key")
        if case .failure = getResult {
            // expected
        } else {
            XCTFail("getCacheSync should reject main-thread usage")
        }
    }
}
