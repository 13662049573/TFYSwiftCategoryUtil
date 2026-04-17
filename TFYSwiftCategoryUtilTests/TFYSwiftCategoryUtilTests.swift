//
//  TFYSwiftCategoryUtilTests.swift
//  TFYSwiftCategoryUtilTests
//
//  Created by 田风有 on 2021/5/9.
//

import XCTest
@testable import TFYSwiftCategoryUtil

final class TFYSwiftCategoryUtilTests: XCTestCase {

    private struct DemoUser: Codable, Equatable, TFYCodable {
        let id: Int
        let name: String
        let tags: [String]
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
    }

    override func tearDownWithError() throws {
        TFYTimer.cancelAllThrottlingTimers()
        TFYTimerManager.shared.cancelAllTimers()
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

}
