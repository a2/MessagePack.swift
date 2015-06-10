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
        XCTAssertEqual(pack(.Int(-1)), makeData([0xff]))
    }

    func testUnpackNegFixint() {
        var unpacked: MessagePackValue?

        unpacked = unpack(makeData([0xff]))
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.Int(-1))

        unpacked = unpack(makeData([0xe0]))
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.Int(-32))
    }

    func testPackPosFixintSigned() {
        XCTAssertEqual(pack(.Int(1)), makeData([0x01]))
    }

    func testUnpackPosFixintSigned() {
        let unpacked = unpack(makeData([0x01]))
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.Int(1))
    }

    func testPackPosFixintUnsigned() {
        XCTAssertEqual(pack(.UInt(42)), makeData([0x2a]))
    }

    func testUnpackPosFixintUnsigned() {
        let unpacked = unpack(makeData([0x2a]))
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.UInt(42))
    }

    func testPackUInt8() {
        XCTAssertEqual(pack(.UInt(0xff)), makeData([0xcc, 0xff]))
    }

    func testUnpackUInt8() {
        let unpacked = unpack(makeData([0xcc, 0xff]))
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.UInt(0xff))
    }

    func testPackUInt16() {
        XCTAssertEqual(pack(.UInt(0xffff)), makeData([0xcd, 0xff, 0xff]))
    }

    func testUnpackUInt16() {
        let unpacked = unpack(makeData([0xcd, 0xff, 0xff]))
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.UInt(0xffff))
    }

    func testPackUInt32() {
        XCTAssertEqual(pack(.UInt(0xffff_ffff)), makeData([0xce, 0xff, 0xff, 0xff, 0xff]))
    }

    func testUnpackUInt32() {
        let unpacked = unpack(makeData([0xce, 0xff, 0xff, 0xff, 0xff]))
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.UInt(0xffff_ffff))
    }

    func testPackUInt64() {
        XCTAssertEqual(pack(.UInt(0xffff_ffff_ffff_ffff)), makeData([0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]))
    }

    func testUnpackUInt64() {
        let unpacked = unpack(makeData([0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]))
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.UInt(0xffff_ffff_ffff_ffff))
    }

    func testPackInt8() {
        XCTAssertEqual(pack(.Int(-0x7f)), makeData([0xd0, 0x81]))
    }

    func testUnpackInt8() {
        let unpacked = unpack(makeData([0xd0, 0x81]))
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.Int(-0x7f))
    }

    func testPackInt16() {
        XCTAssertEqual(pack(.Int(-0x7fff)), makeData([0xd1, 0x80, 0x01]))
    }

    func testUnpackInt16() {
        let unpacked = unpack(makeData([0xd1, 0x80, 0x01]))
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.Int(-0x7fff))
    }

    func testPackInt32() {
        XCTAssertEqual(pack(.Int(-0x1_0000)), makeData([0xd2, 0xff, 0xff, 0x00, 0x00]))
    }

    func testUnpackInt32() {
        let unpacked = unpack(makeData([0xd2, 0xff, 0xff, 0x00, 0x00]))
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.Int(-0x1_0000))
    }

    func testPackInt64() {
        XCTAssertEqual(pack(.Int(-0x1_0000_0000)), makeData([0xd3, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00]))
    }

    func testUnpackInt64() {
        let unpacked = unpack(makeData([0xd3, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00]))
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.Int(-0x1_0000_0000))
    }
}
