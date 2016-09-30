import Foundation
import XCTest
@testable import MessagePack

class NilTests: XCTestCase {
    static var allTests = {
        return [
            ("testLiteralConversion", testLiteralConversion),
            ("testPack", testPack),
            ("testUnpack", testUnpack),
        ]
    }()

    let packed = Data([0xc0])

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = nil
        XCTAssertEqual(implicitValue, MessagePackValue.nil)
    }

    func testPack() {
        XCTAssertEqual(pack(.nil), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, MessagePackValue.nil)
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }
}
