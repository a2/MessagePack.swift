import Foundation
import XCTest
@testable import MessagePack

class SubdataTests: XCTestCase {
    static var allTests = {
        return [
            ("testConversationToSubdata", testConversationToSubdata),
            ("testConversationToSubdataWithExplicityIndexes", testConversationToSubdataWithExplicityIndexes),
            ("testConversationToEmptySubdata", testConversationToEmptySubdata),
        ]
    }()

    func testConversationToSubdata() {
        let data = Data(repeating: 0, count: 0x20)
        let subdata = Subdata(data: data)
        XCTAssertEqual(subdata.base, data)
        XCTAssertEqual(subdata.baseStartIndex, 0)
        XCTAssertEqual(subdata.baseEndIndex, 0x20)
        XCTAssertEqual(subdata.count, 0x20)
        XCTAssertEqual(subdata.data, data)
        XCTAssertFalse(subdata.isEmpty)
    }

    func testConversationToSubdataWithExplicityIndexes() {
        let data = Data(repeating: 0, count: 0x20)
        let subdata = Subdata(data: data, startIndex: 0x10, endIndex: 0x11)
        XCTAssertEqual(subdata.base, data)
        XCTAssertEqual(subdata.baseStartIndex, 0x10)
        XCTAssertEqual(subdata.baseEndIndex, 0x11)
        XCTAssertEqual(subdata.count, 1)
        XCTAssertFalse(subdata.isEmpty)
    }

    func testConversationToEmptySubdata() {
        let data = Data(repeating: 0, count: 0x20)
        let subdata = Subdata(data: data, startIndex: 0x10, endIndex: 0x10)
        XCTAssertEqual(subdata.base, data)
        XCTAssertEqual(subdata.baseStartIndex, 0x10)
        XCTAssertEqual(subdata.baseEndIndex, 0x10)
        XCTAssertEqual(subdata.count, 0)
        XCTAssertEqual(subdata.data, Data())
        XCTAssertTrue(subdata.isEmpty)
    }
}
