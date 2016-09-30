import Foundation
import XCTest
@testable import MessagePack

class DoubleTests: XCTestCase {
    static var allTests = {
        return [
            ("testLiteralConversion", testLiteralConversion),
            ("testPack", testPack),
            ("testUnpack", testUnpack),
        ]
    }()

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = 3.14
        XCTAssertEqual(implicitValue, MessagePackValue.double(3.14))
    }

    let packed = Data([0xcb, 0x40, 0x09, 0x1e, 0xb8, 0x51, 0xeb, 0x85, 0x1f])

    func testPack() {
        XCTAssertEqual(pack(.double(3.14)), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, .double(3.14))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }
}
