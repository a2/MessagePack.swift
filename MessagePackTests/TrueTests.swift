@testable import MessagePack
import XCTest

class TrueTests: XCTestCase {
    let packed = Data([0xc3])

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = true
        XCTAssertEqual(implicitValue, MessagePackValue.bool(true))
    }

    func testPack() {
        XCTAssertEqual(pack(.bool(true)), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, MessagePackValue.bool(true))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }
}
