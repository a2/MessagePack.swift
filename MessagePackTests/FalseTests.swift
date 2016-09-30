@testable import MessagePack
import XCTest

class FalseTests: XCTestCase {
    let packed = Data([0xc2])

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = false
        XCTAssertEqual(implicitValue, MessagePackValue.bool(false))
    }

    func testPack() {
        XCTAssertEqual(pack(.bool(false)), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, .bool(false))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }
}
