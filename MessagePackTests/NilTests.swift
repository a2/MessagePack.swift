@testable import MessagePack
import XCTest

class NilTests: XCTestCase {
    let packed: Data = [0xc0]

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = nil
        XCTAssertEqual(implicitValue, MessagePackValue.Nil)
    }

    func testPack() {
        XCTAssertEqual(pack(.Nil), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.Nil)
    }
}
