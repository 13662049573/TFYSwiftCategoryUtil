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

    func testAsyncCacheRoundTripAndRemoval() async {
        let key = "cache-round-trip"
        let value = CacheModel(id: 7, name: "round-trip")

        let saveResult = await TFYSwiftCacheKit.shared.setCacheAsync(value, forKey: key)
        guard case .success = saveResult else {
            return XCTFail("Expected async save to succeed, got \(saveResult)")
        }

        let containsAfterSave = await TFYSwiftCacheKit.shared.containsCacheAsync(forKey: key)
        XCTAssertTrue(containsAfterSave)

        let loadResult = await TFYSwiftCacheKit.shared.getCacheAsync(CacheModel.self, forKey: key)
        switch loadResult {
        case .success(let loaded):
            XCTAssertEqual(loaded, value)
        case .failure(let error):
            XCTFail("Expected async load to succeed, got \(error.localizedDescription)")
        }

        let removeResult = await TFYSwiftCacheKit.shared.removeCacheAsync(forKey: key)
        guard case .success = removeResult else {
            return XCTFail("Expected remove to succeed, got \(removeResult)")
        }

        let containsAfterRemove = await TFYSwiftCacheKit.shared.containsCacheAsync(forKey: key)
        XCTAssertFalse(containsAfterRemove)
    }

    func testInvalidKeyFailsGracefully() async {
        let result = await TFYSwiftCacheKit.shared.setCacheAsync(CacheModel(id: 2, name: "bad"), forKey: "bad/key")
        switch result {
        case .success:
            XCTFail("Invalid key should not be accepted")
        case .failure(let error):
            XCTAssertEqual(error.localizedDescription, TFYCacheError.invalidKey.localizedDescription)
        }
    }
}
