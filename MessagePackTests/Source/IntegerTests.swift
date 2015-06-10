@testable import MessagePack
import XCTest

class IntegerTests: XCTestCase {
    func testPosLiteralConversion() {
        let implicitValue: MessagePackValue = -1
        XCTAssertEqual(implicitValue, MessagePackValue.Int(-1))
    }

    func testNegLiteralConversion() {
        let implicitValue: MessagePackValue = 42
        XCTAssertEqual(implicitValue, MessagePackValue.UInt(42))
    }

    func testPackNegFixint() {
        XCTAssertEqual(pack(.Int(-1)), [0xff])
    }

    func testUnpackNegFixint() {
        do {
            let unpacked = try unpack([0xff])
            XCTAssertEqual(unpacked, MessagePackValue.Int(-1))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }

        do {
            let unpacked = try unpack([0xe0])
            XCTAssertEqual(unpacked, MessagePackValue.Int(-32))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testPackPosFixintSigned() {
        XCTAssertEqual(pack(.Int(1)), [0x01])
    }

    func testUnpackPosFixintSigned() {
        do {
            let unpacked = try unpack([0x01])
            XCTAssertEqual(unpacked, MessagePackValue.Int(1))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testPackPosFixintUnsigned() {
        XCTAssertEqual(pack(.UInt(42)), [0x2a])
    }

    func testUnpackPosFixintUnsigned() {
        do {
            let unpacked = try unpack([0x2a])
            XCTAssertEqual(unpacked, MessagePackValue.UInt(42))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testPackUInt8() {
        XCTAssertEqual(pack(.UInt(0xff)), [0xcc, 0xff])
    }

    func testUnpackUInt8() {
        do {
            let unpacked = try unpack([0xcc, 0xff])
            XCTAssertEqual(unpacked, MessagePackValue.UInt(0xff))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testPackUInt16() {
        XCTAssertEqual(pack(.UInt(0xffff)), [0xcd, 0xff, 0xff])
    }

    func testUnpackUInt16() {
        do {
            let unpacked = try unpack([0xcd, 0xff, 0xff])
            XCTAssertEqual(unpacked, MessagePackValue.UInt(0xffff))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testPackUInt32() {
        XCTAssertEqual(pack(.UInt(0xffff_ffff)), [0xce, 0xff, 0xff, 0xff, 0xff])
    }

    func testUnpackUInt32() {
        do {
            let unpacked = try unpack([0xce, 0xff, 0xff, 0xff, 0xff])
            XCTAssertEqual(unpacked, MessagePackValue.UInt(0xffff_ffff))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testPackUInt64() {
        XCTAssertEqual(pack(.UInt(0xffff_ffff_ffff_ffff)), [0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
    }

    func testUnpackUInt64() {
        do {
            let unpacked = try unpack([0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
            XCTAssertEqual(unpacked, MessagePackValue.UInt(0xffff_ffff_ffff_ffff))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testPackInt8() {
        XCTAssertEqual(pack(.Int(-0x7f)), [0xd0, 0x81])
    }

    func testUnpackInt8() {
        do {
            let unpacked = try unpack([0xd0, 0x81])
            XCTAssertEqual(unpacked, MessagePackValue.Int(-0x7f))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testPackInt16() {
        XCTAssertEqual(pack(.Int(-0x7fff)), [0xd1, 0x80, 0x01])
    }

    func testUnpackInt16() {
        do {
            let unpacked = try unpack([0xd1, 0x80, 0x01])
            XCTAssertEqual(unpacked, MessagePackValue.Int(-0x7fff))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testPackInt32() {
        XCTAssertEqual(pack(.Int(-0x1_0000)), [0xd2, 0xff, 0xff, 0x00, 0x00])
    }

    func testUnpackInt32() {
        do {
            let unpacked = try unpack([0xd2, 0xff, 0xff, 0x00, 0x00])
            XCTAssertEqual(unpacked, MessagePackValue.Int(-0x1_0000))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testPackInt64() {
        XCTAssertEqual(pack(.Int(-0x1_0000_0000)), [0xd3, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00])
    }

    func testUnpackInt64() {
        do {
            let unpacked = try unpack([0xd3, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00])
            XCTAssertEqual(unpacked, MessagePackValue.Int(-0x1_0000_0000))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }
}
