@testable import MessagePack
import XCTest

class TrueTests: XCTestCase {
    let packed = makeData([0xc3])

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = true
        XCTAssertEqual(implicitValue, MessagePackValue.Bool(true))
    }

    func testPack() {
        XCTAssertEqual(pack(.Bool(true)), packed)
    }

    func testUnpack() {
        let unpacked = unpack(packed)
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.Bool(true))
    }
}
