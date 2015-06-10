@testable import MessagePack
import XCTest

class FalseTests: XCTestCase {
    let packed: Data = [0xc2]

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = false
        XCTAssertEqual(implicitValue, MessagePackValue.Bool(false))
    }

    func testPack() {
        XCTAssertEqual(pack(.Bool(false)), packed)
    }

    func testUnpack() {
        do {
            let unpacked = try unpack(packed)
            XCTAssertEqual(unpacked, MessagePackValue.Bool(false))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }
}
