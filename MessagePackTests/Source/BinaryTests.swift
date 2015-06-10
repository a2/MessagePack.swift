@testable import MessagePack
import XCTest

class BinaryTests: XCTestCase {
    let payload = makeData([0x00, 0x01, 0x02, 0x03, 0x04])
    let packed = makeData([0xc4, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04])

    func testPack() {
        XCTAssertEqual(pack(.Binary(payload)), packed)
    }

    func testUnpack() {
        let unpacked = unpack(packed)
        XCTAssertTrue(unpacked != nil)
        XCTAssertEqual(unpacked!, MessagePackValue.Binary(payload))
    }

    func testPackBin16() {

    }

    func testUnpackBin16() {
        let data = NSMutableData()
        data.appendData(makeData([0xc4, 0xff]))
        data.length = 2 + 0xff

        let unpacked = unpack(data)
        XCTAssert(unpacked != nil)

        let value = NSMutableData()
        value.length = 0xff
        XCTAssertEqual(unpacked!, MessagePackValue.Binary(value))
    }

    func testPackBin32() {
        let value = NSMutableData()
        value.length = 0x100

        let expectedPacked = NSMutableData()
        expectedPacked.appendData(makeData([0xc5, 0x01, 0x00]))
        expectedPacked.length = 3 + 0x100
        XCTAssertEqual(pack(.Binary(value)), expectedPacked)
    }

    func testUnpackBin32() {
        let data = NSMutableData()
        data.appendData(makeData([0xc5, 0x01, 0x00]))
        data.length = 3 + 0x100

        let unpacked = unpack(data)
        XCTAssert(unpacked != nil)

        let value = NSMutableData()
        value.length = 0x100
        XCTAssertEqual(unpacked!, MessagePackValue.Binary(value))
    }

    func testPackBin64() {
        let value = NSMutableData()
        value.length = 0x1_0000

        let expectedPacked = NSMutableData()
        expectedPacked.appendData(makeData([0xc6, 0x00, 0x01, 0x00, 0x00]))
        expectedPacked.length = 5 + 0x1_0000
        XCTAssertEqual(pack(.Binary(value)), expectedPacked)
    }

    func testUnpackBin64() {
        let data = NSMutableData()
        data.appendData(makeData([0xc6, 0x00, 0x01, 0x00, 0x00]))
        data.length = 5 + 0x1_0000

        let unpacked = unpack(data)
        XCTAssert(unpacked != nil)

        let value = NSMutableData()
        value.length = 0x1_0000
        XCTAssertEqual(unpacked!, MessagePackValue.Binary(value))
    }
}
