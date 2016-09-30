import Foundation
import XCTest
@testable import MessagePack

class FalseTests: XCTestCase {
    static var allTests = {
        return [
            ("testLiteralConversion", testLiteralConversion),
            ("testPack", testPack),
            ("testUnpack", testUnpack),
        ]
    }()

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
