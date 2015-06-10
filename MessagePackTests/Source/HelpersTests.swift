@testable import MessagePack
import XCTest

class HelpersTests: XCTestCase {
    func testMakeData() {
        let data = makeData([0x00, 0x01, 0x02, 0x03, 0x04])

        var bytes = [UInt8](count: 5, repeatedValue: 0xff)
        data.getBytes(&bytes, range: NSRange(0..<5))
        XCTAssertEqual(bytes, [0x00, 0x01, 0x02, 0x03, 0x04])
    }

    func testJoinUInt64() {
        let bytes: [UInt8] = [0x12, 0x34, 0x56, 0x78]
        var generator = bytes.generate()

        let integer = joinUInt64(&generator, size: 4)
        XCTAssert(integer != nil)
        XCTAssertEqual(integer!, 0x12345678)
    }

    func testJoinUInt64Failure() {
        let bytes: [UInt8] = [0x12, 0x34, 0x56]
        var generator = bytes.generate()

        let integer = joinUInt64(&generator, size: 4)
        XCTAssert(integer == nil)
    }

    func testJoinString() {
        let bytes: [UInt8] = [0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21]
        var generator = bytes.generate()

        let string = joinString(&generator, length: 13)
        XCTAssert(string != nil)
        XCTAssertEqual(string!, "Hello, world!")
    }

    func testJoinStringFailure() {
        let bytes: [UInt8] = [0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21]
        var generator = bytes.generate()

        let string = joinString(&generator, length: 14)
        XCTAssert(string == nil)
    }

    func testJoinData() {
        let bytes: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04]
        var generator = bytes.generate()

        let data = joinData(&generator, length: 5)
        XCTAssert(data != nil)

        var dataBytes = [UInt8](count: 5, repeatedValue: 0x00)
        data!.getBytes(&dataBytes, range: NSRange(0..<5))

        XCTAssertEqual(dataBytes, bytes)
    }

    func testJoinDataFailure() {
        let bytes: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04]
        var generator = bytes.generate()

        let data = joinData(&generator, length: 6)
        XCTAssert(data == nil)
    }

    func testJoinArray() {
        let bytes: [UInt8] = [0xc0, 0xc0, 0xc0, 0xc0, 0xc0]
        var generator = bytes.generate()

        let array = joinArray(&generator, length: 5)
        XCTAssert(array != nil)

        let expectedArray: [MessagePackValue] = [nil, nil, nil, nil, nil]
        XCTAssertEqual(array!, expectedArray)
    }

    func testJoinArrayFailure() {
        let bytes: [UInt8] = [0xc0, 0xc0, 0xc0, 0xc0, 0xc0]
        var generator = bytes.generate()

        let array = joinArray(&generator, length: 6)
        XCTAssert(array == nil)
    }

    func testJoinMap() {
        let bytes: [UInt8] = [0x00, 0xc0, 0x01, 0xc0, 0x02, 0xc0, 0x03, 0xc0, 0x04, 0xc0]
        var generator = bytes.generate()

        let map = joinMap(&generator, length: 5)
        XCTAssert(map != nil)

        let expectedMap: [MessagePackValue : MessagePackValue] = [
            0: nil, 1: nil, 2: nil, 3: nil, 4: nil,
        ]
        XCTAssertEqual(map!, expectedMap)
    }

    func testJoinMapFailure() {
        let bytes: [UInt8] = [0x00, 0xc0, 0x01, 0xc0, 0x02, 0xc0, 0x03, 0xc0, 0x04, 0xc0]
        var generator = bytes.generate()

        let map = joinMap(&generator, length: 6)
        XCTAssert(map == nil)
    }

    func testSplitInt() {
        XCTAssertEqual(splitInt(0x12, parts: 1), [0x12])
        XCTAssertEqual(splitInt(0x1234, parts: 2), [0x12, 0x34])
        XCTAssertEqual(splitInt(0x1234_5678, parts: 4), [0x12, 0x34, 0x56, 0x78])
        XCTAssertEqual(splitInt(0x1234_5678_9abc_def0, parts: 8), [0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0])
    }

    func testPackIntPos() {
        XCTAssertEqual(packIntPos(0), [0x00])
        XCTAssertEqual(packIntPos(0x80), [0xcc, 0x80])
        XCTAssertEqual(packIntPos(0x100), [0xcd, 0x01, 0x00])
        XCTAssertEqual(packIntPos(0x1_0000), [0xce, 0x00, 0x01, 0x00, 0x00])
        XCTAssertEqual(packIntPos(0x1_0000_0000_0000), [0xcf, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    }

    func testPackIntNeg() {
        XCTAssertEqual(packIntNeg(-0x20), [0xe0])
        XCTAssertEqual(packIntNeg(-0x7f), [0xd0, 0x81])
        XCTAssertEqual(packIntNeg(-0x7fff), [0xd1, 0x80, 0x01])
        XCTAssertEqual(packIntNeg(-0x7fff_ffff), [0xd2, 0x80, 0x00, 0x00, 0x01])
        XCTAssertEqual(packIntNeg(-0x7fff_ffff_ffff_ffff), [0xd3, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01])
    }

    func testFlatten() {
        let dict = [1: 1, 2: 2, 3: 3, 4: 4]
        let flat = flatten(dict)

        for i in stride(from: 0, to: 8, by: 2) {
            XCTAssert(1...4 ~= flat[i])
            XCTAssertEqual(flat[i], flat[i + 1])
        }
    }
}
