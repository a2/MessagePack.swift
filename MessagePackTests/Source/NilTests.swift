@testable import MessagePack
import XCTest

class NilTests: XCTestCase {
    let packed = makeData([0xc0])

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = nil
        XCTAssertEqual(implicitValue, MessagePackValue.Nil)
    }

    func testPack() {
        XCTAssertEqual(pack(.Nil), packed)
    }

    func testUnpack() {
        let unpacked = unpack(packed)
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.Nil)
    }
}
