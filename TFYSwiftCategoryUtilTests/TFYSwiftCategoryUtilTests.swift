//
//  TFYSwiftCategoryUtilTests.swift
//  TFYSwiftCategoryUtilTests
//
//  Created by 田风有 on 2021/5/9.
//

import CoreLocation
import XCTest
@testable import TFYSwiftCategoryUtil

@objcMembers
private final class RuntimeProbe: NSObject {
    func greeting() -> NSString {
        return "hello"
    }

    func echo(_ value: NSString) -> NSString {
        return value
    }

    func combine(_ first: NSString, second: NSString) -> NSString {
        return "\(first)-\(second)" as NSString
    }
}

private var runtimeProbeAssociationKey: UInt8 = 0

private final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let requestHandler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: TFYURLSessionError.invalidResponse)
            return
        }

        do {
            let (response, data) = try requestHandler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

final class TFYSwiftCategoryUtilTests: XCTestCase {

    private struct DemoUser: Codable, Equatable, TFYCodable {
        let id: Int
        let name: String
        let tags: [String]
    }

    private struct PrettyPayload: Codable, TFYCodable {
        let name: String
        let id: Int
    }

    private struct AlwaysThrowingPayload: Decodable {
        init(from decoder: any Decoder) throws {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "intentional failure")
            )
        }
    }

    override func setUpWithError() throws {
        TFYTimer.cancelAllThrottlingTimers()
        TFY<DispatchQueue>.resetAllOnceTokens()
    }

    override func tearDownWithError() throws {
        TFYTimer.cancelAllThrottlingTimers()
        TFYTimerManager.shared.cancelAllTimers()
        TFY<DispatchQueue>.resetAllOnceTokens()
        MockURLProtocol.requestHandler = nil
    }

    private func recursiveSize(of url: URL) throws -> Int64 {
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .fileSizeKey]
        let values = try url.resourceValues(forKeys: resourceKeys)

        if values.isDirectory == true {
            return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: Array(resourceKeys))
                .reduce(0) { partial, childURL in
                    try partial + recursiveSize(of: childURL)
                }
        }

        return Int64(values.fileSize ?? 0)
    }

    func testTFYSwiftJsonKitExtractValueSupportsNestedPaths() throws {
        let json: [String: Any] = [
            "user": [
                "profile": [
                    "name": "TFY"
                ],
                "tags": ["swift", "ios"]
            ]
        ]

        XCTAssertEqual(TFYSwiftJsonKit.extractValue(from: json, at: "user.profile.name") as? String, "TFY")
        XCTAssertEqual(TFYSwiftJsonKit.extractValue(from: json, at: "user.tags.1") as? String, "ios")
        XCTAssertNil(TFYSwiftJsonKit.extractValue(from: json, at: "user.tags.99"))
    }

    func testTFYSwiftJsonKitValidateSchemaRejectsMissingRequiredField() throws {
        let schema: [String: Any] = [
            "type": "object",
            "required": ["id", "name"],
            "properties": [
                "id": ["type": "integer"],
                "name": ["type": "string"]
            ]
        ]

        XCTAssertTrue(TFYSwiftJsonKit.validateSchema(["id": 1, "name": "TFY"], against: schema))
        XCTAssertFalse(TFYSwiftJsonKit.validateSchema(["id": 1], against: schema))
    }

    func testTFYSwiftJsonKitStringParsingHelpersSupportDictionaryAndArray() throws {
        let dictionaryString = #"{"id":1,"name":"TFY"}"#
        let arrayString = #"[{"id":1},{"id":2}]"#

        switch TFYSwiftJsonKit.dictionary(from: dictionaryString) {
        case .success(let dict):
            XCTAssertEqual(dict["name"] as? String, "TFY")
        case .failure(let error):
            XCTFail("Expected dictionary parsing to succeed, got \(error)")
        }

        switch TFYSwiftJsonKit.array(from: arrayString) {
        case .success(let array):
            XCTAssertEqual((array[1] as? [String: Int])?["id"], 2)
        case .failure(let error):
            XCTFail("Expected array parsing to succeed, got \(error)")
        }
    }

    func testDictionarySetValueRejectsTypeMismatchWithoutMutating() throws {
        var dictionary = ["count": 1]

        let result = dictionary.setValue(keys: ["count"], newValue: "wrong")

        XCTAssertFalse(result)
        XCTAssertEqual(dictionary["count"], 1)
    }

    func testTFYCodablePrettyStringUsesStableSortedKeys() throws {
        let payload = PrettyPayload(name: "TFY", id: 7)
        let pretty = try XCTUnwrap(payload.toPrettyString())

        let idRange = try XCTUnwrap(pretty.range(of: "\"id\""))
        let nameRange = try XCTUnwrap(pretty.range(of: "\"name\""))

        XCTAssertLessThan(idRange.lowerBound, nameRange.lowerBound)
        XCTAssertTrue(pretty.contains("\n"))
    }

    func testDataSafeSubdataAllowsEmptySlice() throws {
        let data = Data([0x10, 0x20, 0x30])
        let slice = try XCTUnwrap(data.safeSubdata(from: 1, to: 1))

        XCTAssertEqual(slice, Data())
    }

    func testBundleSizeIncludesNestedResources() throws {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("bundle")
        try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDirectory) }

        let infoPlistURL = tempDirectory.appendingPathComponent("Info.plist")
        let plistData = try PropertyListSerialization.data(
            fromPropertyList: ["CFBundleIdentifier": "com.tfy.bundle.tests"],
            format: .xml,
            options: 0
        )
        try plistData.write(to: infoPlistURL)

        let nestedDirectory = tempDirectory.appendingPathComponent("Nested")
        try fileManager.createDirectory(at: nestedDirectory, withIntermediateDirectories: true)
        let nestedFileURL = nestedDirectory.appendingPathComponent("payload.json")
        let nestedData = Data(repeating: 0xAB, count: 256)
        try nestedData.write(to: nestedFileURL)

        let bundle = try XCTUnwrap(Bundle(path: tempDirectory.path))
        let expectedSize = try recursiveSize(of: tempDirectory)

        XCTAssertEqual(bundle.size(), expectedSize)
    }

    func testTFYCodableGetChangesTracksAddedUpdatedAndRemovedFields() throws {
        let original = DemoUser(id: 1, name: "Old", tags: ["swift"])
        let updated = DemoUser(id: 1, name: "New", tags: ["swift", "ios"])

        let changes = updated.getChanges(from: original)

        XCTAssertEqual((changes["name"] as? [String: String])?["old"], "Old")
        XCTAssertEqual((changes["name"] as? [String: String])?["new"], "New")

        let tagChanges = changes["tags"] as? [String: [String]]
        XCTAssertEqual(tagChanges?["old"] ?? [], ["swift"])
        XCTAssertEqual(tagChanges?["new"] ?? [], ["swift", "ios"])
    }

    func testTFYTimerRescheduledHandlerUpdatesExecutionStatistics() throws {
        let expectation = expectation(description: "rescheduled timer fires")
        let queue = DispatchQueue(label: "tfy.timer.tests")
        let timer = TFYTimer(interval: .milliseconds(20), repeats: false, queue: queue) { _ in
            XCTFail("original handler should be replaced")
        }

        timer.rescheduleHandler { firedTimer in
            XCTAssertEqual(firedTimer.executionCount, 1)
            XCTAssertNotNil(firedTimer.lastExecution)
            expectation.fulfill()
        }

        timer.start()
        wait(for: [expectation], timeout: 1.0)
    }

    func testTFYCountDownTimerProgressIsSafeForZeroTimes() throws {
        let timer = TFYCountDownTimer(interval: .seconds(1), times: 0) { _, _ in }

        XCTAssertEqual(timer.totalTimes, 0)
        XCTAssertEqual(timer.remainingTimes, 0)
        XCTAssertEqual(timer.progress, 0)
        XCTAssertTrue(timer.isCompleted)
    }

    func testDispatchTimeIntervalConversionsRemainConsistent() throws {
        XCTAssertEqual(DispatchTimeInterval.seconds(2).seconds, 2)
        XCTAssertEqual(DispatchTimeInterval.milliseconds(250).seconds, 0.25, accuracy: 0.0001)
        XCTAssertEqual(DispatchTimeInterval.fromSeconds(1.5).seconds, 1.5, accuracy: 0.001)
    }

    func testWKWebHandlerGenericInitDoesNotCrashWhenPayloadIntrospectionFails() throws {
        let handler = WKWebHandler("broken") { (_: AlwaysThrowingPayload) in
            XCTFail("action should not be invoked during initialization")
        }

        XCTAssertEqual(handler.name, "broken")
        XCTAssertTrue(handler.javaScript.contains("broken"))
    }
    
    func testDispatchQueueSyncDoesNotDeadlockOnMainThread() {
        let expectation = expectation(description: "sync executes immediately")
        DispatchQueue.main.async {
            DispatchQueue.sync {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDispatchQueueOnceRunsBlockOnlyOnceForSameToken() {
        var counter = 0
        TFY<DispatchQueue>.once(token: "once.token.test") {
            counter += 1
        }
        TFY<DispatchQueue>.once(token: "once.token.test") {
            counter += 1
        }
        XCTAssertEqual(counter, 1)
    }

    func testDispatchQueueOnceCanBeResetAndReused() {
        let token = "once.token.reset"
        var counter = 0

        TFY<DispatchQueue>.once(token: token) {
            counter += 1
        }
        XCTAssertTrue(TFY<DispatchQueue>.hasExecuted(token: token))

        TFY<DispatchQueue>.resetOnce(token: token)
        XCTAssertFalse(TFY<DispatchQueue>.hasExecuted(token: token))

        TFY<DispatchQueue>.once(token: token) {
            counter += 1
        }

        XCTAssertEqual(counter, 2)
    }

    func testDispatchQueueOnceWithEmptyTokenExecutesEachTime() {
        var counter = 0

        TFY<DispatchQueue>.once(token: "") {
            counter += 1
        }
        TFY<DispatchQueue>.once(token: "") {
            counter += 1
        }

        XCTAssertEqual(counter, 2)
    }

    func testFileManagerWriteToFileCreatesMissingParentDirectory() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }

        let targetFile = root.appendingPathComponent("nested/path/payload.txt")
        let result = TFY<FileManager>.writeToFile(writeType: .textType, content: "hello", writePath: targetFile.path)

        XCTAssertTrue(result.isSuccess, result.error)
        XCTAssertEqual(try String(contentsOf: targetFile, encoding: .utf8), "hello")
    }

    func testFileManagerCopyFileCreatesMissingDestinationDirectory() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let sourceDirectory = root.appendingPathComponent("source")
        let sourceFile = sourceDirectory.appendingPathComponent("payload.txt")
        let destinationFile = root.appendingPathComponent("nested/destination/copied.txt")

        try FileManager.default.createDirectory(at: sourceDirectory, withIntermediateDirectories: true)
        try Data("copy".utf8).write(to: sourceFile)
        defer { try? FileManager.default.removeItem(at: root) }

        let result = TFY<FileManager>.copyFile(type: .file, fromFilePath: sourceFile.path, toFilePath: destinationFile.path)

        XCTAssertTrue(result.isSuccess, result.error)
        XCTAssertEqual(try Data(contentsOf: destinationFile), Data("copy".utf8))
    }

    func testFileManagerMoveFileCreatesMissingDestinationDirectory() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let sourceDirectory = root.appendingPathComponent("source")
        let sourceFile = sourceDirectory.appendingPathComponent("payload.txt")
        let destinationFile = root.appendingPathComponent("nested/destination/moved.txt")

        try FileManager.default.createDirectory(at: sourceDirectory, withIntermediateDirectories: true)
        try Data("move".utf8).write(to: sourceFile)
        defer { try? FileManager.default.removeItem(at: root) }

        let result = TFY<FileManager>.moveFile(type: .file, fromFilePath: sourceFile.path, toFilePath: destinationFile.path)

        XCTAssertTrue(result.isSuccess, result.error)
        XCTAssertFalse(FileManager.default.fileExists(atPath: sourceFile.path))
        XCTAssertEqual(try Data(contentsOf: destinationFile), Data("move".utf8))
    }

    func testFileManagerSizeValueIncludesNestedDirectories() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let nestedDirectory = root.appendingPathComponent("a/b")
        let topFile = root.appendingPathComponent("top.bin")
        let nestedFile = nestedDirectory.appendingPathComponent("nested.bin")

        try FileManager.default.createDirectory(at: nestedDirectory, withIntermediateDirectories: true)
        try Data(repeating: 0x01, count: 128).write(to: topFile)
        try Data(repeating: 0x02, count: 256).write(to: nestedFile)
        defer { try? FileManager.default.removeItem(at: root) }

        XCTAssertEqual(TFY<FileManager>.fileOrDirectorySizeValue(path: root.path), 384)
    }

    func testNotificationCenterObserveAndRemoveToken() {
        let center = NotificationCenter()
        let name = Notification.Name("observe.remove.token")
        let expectation = expectation(description: "notification received once")
        expectation.expectedFulfillmentCount = 1

        var receivedCount = 0
        let token = center.observe(name: name, object: nil, queue: nil) { notification in
            receivedCount += 1
            XCTAssertEqual(notification.name, name)
            expectation.fulfill()
        }

        center.post(name: name, object: nil)
        wait(for: [expectation], timeout: 1.0)

        center.removeObserverToken(token)
        center.post(name: name, object: nil)

        XCTAssertEqual(receivedCount, 1)
    }

    func testNotificationCenterPostDelayedNormalizesNegativeDelay() {
        let center = NotificationCenter()
        let name = Notification.Name("negative.delay.notification")
        let expectation = expectation(description: "notification delivered")

        let token = center.observe(name: name, object: nil, queue: .main) { _ in
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        defer { center.removeObserverToken(token) }

        center.postDelayed(name: name, delay: -1)
        wait(for: [expectation], timeout: 1.0)
    }

    func testNumberFormatterParsesTrimmedDecimalWithPOSIXLocale() throws {
        let number = try XCTUnwrap(TFY<NumberFormatter>.number(from: "  1234.50\n"))

        XCTAssertEqual(number.doubleValue, 1234.5, accuracy: 0.0001)
    }

    func testNumberFormatterStableStringUsesRequestedFractionDigits() throws {
        let value = NSNumber(value: 1234.5)
        let formatted = try XCTUnwrap(
            TFY<NumberFormatter>.string(from: value, minimumFractionDigits: 2, maximumFractionDigits: 2)
        )

        XCTAssertEqual(formatted, "1234.50")
    }

    func testNumberFormatterRejectsInvalidGroupingSize() {
        let formatted = TFY<NumberFormatter>.setGroupingSeparatorAndSize(
            value: "123456",
            separator: ",",
            groupingSize: 0
        )

        XCTAssertNil(formatted)
    }

    func testDateFormatterPOSIXProducesStableUTCString() {
        let formatter = DateFormatter.posix(format: "yyyy-MM-dd HH:mm:ss")
        let date = Date(timeIntervalSince1970: 0)

        XCTAssertEqual(formatter.string(from: date), "1970-01-01 00:00:00")
    }

    func testDateFormatterSafeDateTrimsWhitespace() throws {
        let formatter = DateFormatter.posix(format: "yyyy-MM-dd")
        let date = try XCTUnwrap(formatter.safeDate(from: " 1970-01-02 "))

        XCTAssertEqual(date.timeIntervalSince1970, 86_400, accuracy: 0.001)
    }

    func testDateSafeTimestampParsingSupportsMillisecondsAndRejectsInvalidInput() throws {
        let date = try XCTUnwrap(Date.tfy.date(fromTimestamp: "1000000000123"))

        XCTAssertEqual(date.timeIntervalSince1970, 1_000_000_000.123, accuracy: 0.001)
        XCTAssertNil(Date.tfy.date(fromTimestamp: "bad timestamp"))
    }

    func testDateSafeFormattedParsingTrimsAndUsesPOSIXLocale() throws {
        let date = try XCTUnwrap(
            Date.tfy.date(
                from: " 1970-01-02 00:00:00 ",
                formatter: "yyyy-MM-dd HH:mm:ss",
                timeZone: TimeZone(secondsFromGMT: 0) ?? .current
            )
        )

        XCTAssertEqual(date.timeIntervalSince1970, 86_400, accuracy: 0.001)
    }

    func testDateEndOfMonthAndEndOfYear() throws {
        let formatter = DateFormatter.posix(format: "yyyy-MM-dd HH:mm:ss", timeZone: .current)
        let date = try XCTUnwrap(formatter.date(from: "2024-02-10 12:00:00"))

        XCTAssertEqual(formatter.string(from: date.tfy.endOfMonth()), "2024-02-29 23:59:59")
        XCTAssertEqual(formatter.string(from: date.tfy.endOfYear()), "2024-12-31 23:59:59")
    }

    func testNSNumberSafeResultRejectsDivisionByZero() {
        let number = NSNumber(value: 10)
        let result = number.tfy.safeResult(
            oneNumber: number,
            type: .TFYSwiftDiv,
            twoNumber: NSNumber(value: 0)
        )

        XCTAssertNil(result)
        XCTAssertEqual(number.tfy.getResult(oneNumber: number, type: .TFYSwiftDiv, twoNumber: NSNumber(value: 0)).intValue, 0)
    }

    func testNSNumberNegativeDurationsAndDistancesClampToZero() {
        XCTAssertEqual(NSNumber(value: -3).rounded(to: -2), NSNumber(value: -3))
        XCTAssertEqual(NSNumber(value: -90).toTimeIntervalString(), "00:00")
        XCTAssertEqual(NSNumber(value: -10).toDistanceString(), "0m")
        XCTAssertEqual(NSNumber(value: -500).toWeightString(), "0g")
    }

    func testNSRangeClampAndSafeMoveStayInsideBounds() {
        let range = NSRange(location: -4, length: 20)

        XCTAssertEqual(range.tfy.clamped(to: 6), NSRange(location: 0, length: 6))
        XCTAssertEqual(NSRange(location: 3, length: 4).tfy.safelyMoved(by: 10, in: 8), NSRange(location: 4, length: 4))
        XCTAssertFalse(NSRange(location: 4, length: 3).tfy.isValid(in: 5))
    }

    func testNSRangeSubrangeRejectsNegativeInput() {
        let range = NSRange(location: 2, length: 5)

        XCTAssertNil(range.subrange(offset: -1, length: 2))
        XCTAssertNil(range.subrange(offset: 1, length: -2))
        XCTAssertEqual(range.subrange(offset: 1, length: 2), NSRange(location: 3, length: 2))
    }

    func testNSMutableAttributedStringAddAttributeClampsPartiallyOutOfBoundsRange() {
        let attributedString = NSMutableAttributedString(string: "Hello")

        attributedString.tfy.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 3, length: 10))

        XCTAssertNil(attributedString.attribute(.foregroundColor, at: 2, effectiveRange: nil))
        XCTAssertNotNil(attributedString.attribute(.foregroundColor, at: 3, effectiveRange: nil))
        XCTAssertNotNil(attributedString.attribute(.foregroundColor, at: 4, effectiveRange: nil))
    }

    func testNSMutableAttributedStringAddAttributeIgnoresFullyOutOfBoundsRange() {
        let attributedString = NSMutableAttributedString(string: "Hello")

        attributedString.tfy.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 99, length: 2))

        XCTAssertNil(attributedString.attribute(.foregroundColor, at: 0, effectiveRange: nil))
    }

    func testNSAttributedStringRangeAttributesClampPartiallyOutOfBoundsRange() {
        let attributedString = NSAttributedString(string: "Hello")
        let result = attributedString.tfy.setSpecificRangeTextColor(
            color: .red,
            range: NSRange(location: 3, length: 20)
        )

        XCTAssertNil(result.attribute(.foregroundColor, at: 2, effectiveRange: nil))
        XCTAssertNotNil(result.attribute(.foregroundColor, at: 3, effectiveRange: nil))
        XCTAssertNotNil(result.attribute(.foregroundColor, at: 4, effectiveRange: nil))
    }

    func testNSAttributedStringFactorySkipsMissingTapRanges() {
        let attributedString = NSAttributedString.create(
            "Hello",
            textTaps: ["Missing"],
            font: .systemFont(ofSize: 12),
            tapFont: .boldSystemFont(ofSize: 12)
        )

        XCTAssertEqual(attributedString.string, "Hello")
        XCTAssertEqual(attributedString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor, UIColor.black)
    }

    func testNSAttributedStringAttributesClampIndex() {
        let attributedString = NSAttributedString(
            string: "Hello",
            attributes: [.foregroundColor: UIColor.red]
        )

        let attributes = attributedString.attributes(at: 99)

        XCTAssertEqual(attributes.0, NSRange(location: 0, length: 5))
        XCTAssertNotNil(attributes.1[.foregroundColor])
    }

    func testNSObjectPerformSupportsZeroOneAndTwoArguments() {
        let probe = RuntimeProbe()

        XCTAssertEqual(probe.perform(#selector(RuntimeProbe.greeting)) as? NSString, "hello")
        XCTAssertEqual(probe.perform(#selector(RuntimeProbe.echo(_:)), with: ["swift" as NSString]) as? NSString, "swift")
        XCTAssertEqual(
            probe.perform(#selector(RuntimeProbe.combine(_:second:)), with: ["tfy" as NSString, "kit" as NSString]) as? NSString,
            "tfy-kit"
        )
        XCTAssertNil(probe.perform(#selector(RuntimeProbe.greeting), with: [1, 2, 3]))
    }

    func testNSObjectAssociatedObjectUsesRawPointerKeySafely() {
        let probe = RuntimeProbe()
        let key = withUnsafePointer(to: &runtimeProbeAssociationKey) { UnsafeRawPointer($0) }

        probe.associate(retainObject: "value" as NSString, forKey: key)
        XCTAssertEqual(probe.associatedObject(forKey: key) as? NSString, "value")

        probe.removeAssociatedObject(forKey: key)
        XCTAssertNil(probe.associatedObject(forKey: key))
    }

    func testUserDefaultsDefaultValuesAreReturnedForMissingKeys() throws {
        let suiteName = "tfy.user.defaults.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        XCTAssertEqual(defaults.tfy.integer(forKey: "missingInt", defaultValue: 42), 42)
        XCTAssertEqual(defaults.tfy.float(forKey: "missingFloat", defaultValue: 3.5), 3.5)
        XCTAssertEqual(defaults.tfy.double(forKey: "missingDouble", defaultValue: 8.25), 8.25)
        XCTAssertTrue(defaults.tfy.bool(forKey: "missingBool", defaultValue: true))
    }

    func testUserDefaultsRejectsInvalidPropertyListValuesAndEmptyKeys() throws {
        let suiteName = "tfy.user.defaults.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.tfy
            .set(RuntimeProbe(), forKey: "invalidObject")
            .set("ignored", forKey: "")
            .setValues(["valid": "ok", "invalid": RuntimeProbe()])

        XCTAssertNil(defaults.object(forKey: "invalidObject"))
        XCTAssertNil(defaults.object(forKey: ""))
        XCTAssertEqual(defaults.string(forKey: "valid"), "ok")
        XCTAssertNil(defaults.object(forKey: "invalid"))
    }

    func testURLSafeCreationAndQueryHelpers() throws {
        let url = try XCTUnwrap(URL.tfy.safe(" https://example.com/api?name=old "))

        XCTAssertTrue(url.tfy.isHTTPURL)
        XCTAssertEqual(url.tfy.value(forQueryItem: "name"), "old")

        let updatedURL = url.tfy.appendingQueryItems(
            [
                URLQueryItem(name: "name", value: "new"),
                URLQueryItem(name: "", value: "ignored"),
                URLQueryItem(name: "page", value: "1")
            ],
            replacingExisting: true
        )

        XCTAssertEqual(updatedURL.tfy.value(forQueryItem: "name"), "new")
        XCTAssertEqual(updatedURL.tfy.value(forQueryItem: "page"), "1")
        XCTAssertNil(updatedURL.tfy.deletingAllQueryItems().query)
    }

    func testURLRequestBuildsHeadersQueryAndJSONBodySafely() throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/search"))
        let request = URLRequest.tfy.request(
            url: url,
            method: .post,
            queryItems: [URLQueryItem(name: "q", value: "swift")],
            headers: ["X-Test": "1", "": "ignored"],
            timeout: 0
        )
        .tfy
        .acceptJSON()
        .bearerToken(" token ")
        .jsonBody(["name": "tfy"])
        .timeout(-3)
        .build

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.tfy.value(forQueryItem: "q"), "swift")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Test"), "1")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token")
        XCTAssertEqual(request.timeoutInterval, 0.1)

        let body = try XCTUnwrap(request.httpBody)
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: body) as? [String: String])
        XCTAssertEqual(object["name"], "tfy")
    }

    func testURLSessionAsyncDataValidatesSuccessfulHTTPStatus() async throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/success"))
        MockURLProtocol.requestHandler = { request in
            let response = try XCTUnwrap(
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 201, httpVersion: nil, headerFields: nil)
            )
            return (response, Data("ok".utf8))
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }

        let (data, response) = try await session.tfy.data(for: URLRequest(url: url))

        XCTAssertEqual(response.statusCode, 201)
        XCTAssertEqual(String(data: data, encoding: .utf8), "ok")
    }

    func testURLSessionAsyncDataRejectsUnexpectedHTTPStatus() async throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/missing"))
        MockURLProtocol.requestHandler = { request in
            let response = try XCTUnwrap(
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 404, httpVersion: nil, headerFields: nil)
            )
            return (response, Data("missing".utf8))
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }

        do {
            _ = try await session.tfy.data(for: URLRequest(url: url))
            XCTFail("Expected URLSession helper to reject 404 response")
        } catch TFYURLSessionError.unacceptableStatusCode(let statusCode, let data) {
            XCTAssertEqual(statusCode, 404)
            XCTAssertEqual(String(data: data, encoding: .utf8), "missing")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCALayerGeometryAndSnapshotHandleInvalidValuesSafely() {
        let layer = CALayer()

        layer.width = -10
        layer.height = -20
        layer.setLayerShadow(color: .black, offset: .zero, radius: -4)

        XCTAssertEqual(layer.width, 0)
        XCTAssertEqual(layer.height, 0)
        XCTAssertEqual(layer.shadowRadius, 0)
        XCTAssertNil(layer.snapshotImage())
    }

    func testCAGradientLayerNormalizesColorsAndLocations() {
        let layer = CAGradientLayer()

        layer.tfy.gradientLayer(
            .vertical,
            [UIColor.red, UIColor.blue, "ignored"],
            [NSNumber(value: 1), NSNumber(value: 0)]
        )

        XCTAssertEqual(layer.colors?.count, 2)
        XCTAssertEqual(layer.locations, [0, 1])
        XCTAssertEqual(layer.startPoint, CGPoint(x: 0, y: 0))
        XCTAssertEqual(layer.endPoint, CGPoint(x: 0, y: 1))
    }

    func testCATextLayerClampsNumericStyleInputs() {
        let layer = CATextLayer()

        layer
            .text("Hello")
            .font(12)
            .lineSpacing(-4)
            .textShadow(color: .black, offset: .zero, radius: -2)
            .border(color: .red, width: -3)
            .cornerRadius(-8)
            .opacity(2)
            .frame(CGRect(x: 0, y: 0, width: -10, height: -20))
            .anchorPoint(CGPoint(x: -1, y: 2))

        XCTAssertEqual(layer.fontSize, 12)
        XCTAssertEqual(layer.shadowRadius, 0)
        XCTAssertEqual(layer.borderWidth, 0)
        XCTAssertEqual(layer.cornerRadius, 0)
        XCTAssertEqual(layer.opacity, 1)
        XCTAssertEqual(layer.frame.size, CGSize(width: 10, height: 20))
        XCTAssertEqual(layer.anchorPoint, CGPoint(x: 0, y: 1))

        guard let attributedString = layer.string as? NSAttributedString else {
            XCTFail("Expected text layer string to become attributed after setting line spacing")
            return
        }
        let paragraphStyle = attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
        XCTAssertEqual(paragraphStyle?.lineSpacing, 0)
    }

    func testCLLocationCoordinateValidationAndBearingAreStable() {
        XCTAssertTrue(CLLocation.tfy.isValidCoordinate(latitude: 0, longitude: 0))
        XCTAssertFalse(CLLocation.tfy.isValidCoordinate(latitude: 91, longitude: 0))
        XCTAssertFalse(CLLocation.tfy.isValidCoordinate(latitude: 0, longitude: 181))
        XCTAssertFalse(CLLocation.tfy.isValidCoordinate(latitude: CLLocationDegrees.nan, longitude: 0))

        let origin = CLLocation(latitude: 0, longitude: 0)
        let east = CLLocation(latitude: 0, longitude: 1)
        let bearing = CLLocation.tfy.bearing(from: origin, to: east)

        XCTAssertEqual(bearing, 90, accuracy: 0.001)
        XCTAssertTrue((0..<360).contains(bearing))
    }

    func testCLLocationDescriptionClampsNegativeAccuracy() {
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 23, longitude: 113),
            altitude: 0,
            horizontalAccuracy: -1,
            verticalAccuracy: -1,
            timestamp: Date()
        )

        XCTAssertTrue(CLLocation.tfy.description(for: location).contains("精度: 0.0m"))
    }

    func testTimerHelpersNormalizeInvalidIntervals() {
        let timer = Timer(safeTimerWithTimeInterval: -5, repeats: false) { _ in }
        defer { timer.invalidate() }

        XCTAssertEqual(timer.timeInterval, Timer.tfy_safeInterval(-5))
        XCTAssertEqual(Timer.tfy_safeInterval(.nan), 0.001)
        XCTAssertEqual(Timer.tfy_safeInterval(0), 0.001)
        XCTAssertEqual(Timer.tfy_safeInterval(2), 2)
    }

    func testUIActivityIndicatorClampsSizeAndAlpha() {
        let indicator = UIActivityIndicatorView.standard()

        indicator.tfy
            .size(CGSize(width: -10, height: 20))
            .alpha(2)

        XCTAssertEqual(indicator.frame.size, CGSize(width: 0, height: 20))
        XCTAssertEqual(indicator.alpha, 1)

        let customIndicator = UIActivityIndicatorView.custom(size: CGSize(width: 12, height: -6), color: .red)
        XCTAssertEqual(customIndicator.frame.size, CGSize(width: 12, height: 0))
        XCTAssertTrue(customIndicator.hidesWhenStopped)
        XCTAssertTrue(UIActivityIndicatorView.large().hidesWhenStopped)
        XCTAssertTrue(UIActivityIndicatorView.medium().hidesWhenStopped)
    }

}
