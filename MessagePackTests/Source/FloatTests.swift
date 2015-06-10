@testable import MessagePack
import XCTest

class FloatTests: XCTestCase {
    let packed = makeData([0xca, 0x40, 0x48, 0xf5, 0xc3])

    func testPack() {
        XCTAssertEqual(pack(.Float(3.14)), packed)
    }

    func testUnpack() {
        let unpacked = unpack(packed)
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.Float(3.14))
    }
}
