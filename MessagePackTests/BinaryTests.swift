@testable import MessagePack
import XCTest

class BinaryTests: XCTestCase {
    let payload: Data = [0x00, 0x01, 0x02, 0x03, 0x04]
    let packed: Data = [0xc4, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04]

    func testPack() {
        XCTAssertEqual(pack(.Binary(payload)), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.Binary(payload))
    }

    func testPackBin16() {
        let value = Data(count: 0xff, repeatedValue: 0x00)
        let expectedPacked = [0xc4, 0xff] + value
        XCTAssertEqual(pack(.Binary(value)), expectedPacked)
    }

    func testUnpackBin16() {
        let data = [0xc4, 0xff] + Data(count: 0xff, repeatedValue: 0x00)
        let value = Data(count: 0xff, repeatedValue: 0x00)

        let unpacked = try? unpack(data)
        XCTAssertEqual(unpacked, MessagePackValue.Binary(value))
    }

    func testPackBin32() {
        let value = Data(count: 0x100, repeatedValue: 0x00)
        let expectedPacked = [0xc5, 0x01, 0x00] + value
        XCTAssertEqual(pack(.Binary(value)), expectedPacked)
    }

    func testUnpackBin32() {
        let data =  [0xc5, 0x01, 0x00] + Data(count: 0x100, repeatedValue: 0x00)
        let value = Data(count: 0x100, repeatedValue: 0x00)

        let unpacked = try? unpack(data)
        XCTAssertEqual(unpacked, MessagePackValue.Binary(value))
    }

    func testPackBin64() {
        let value = Data(count: 0x1_0000, repeatedValue: 0x00)
        let expectedPacked = [0xc6, 0x00, 0x01, 0x00, 0x00] + value
        XCTAssertEqual(pack(.Binary(value)), expectedPacked)
    }

    func testUnpackBin64() {
        let data = [0xc6, 0x00, 0x01, 0x00, 0x00] + Data(count: 0x1_0000, repeatedValue: 0x00)
        let value = Data(count: 0x1_0000, repeatedValue: 0x00)

        let unpacked = try? unpack(data)
        XCTAssertEqual(unpacked, MessagePackValue.Binary(value))
    }

    func testUnpackInsufficientData() {
        let dataArray: [Data] = [
            // only type byte
            [0xc4], [0xc5], [0xc6],

            // type byte with no data
            [0xc4, 0x01],
            [0xc5, 0x00, 0x01],
            [0xc6, 0x00, 0x00, 0x00, 0x01],
        ]
        for data in dataArray {
            do {
                try unpack(data)
                XCTFail("Expected unpack to throw")
            } catch {
                XCTAssertEqual(error as? MessagePackError, .InsufficientData)
            }
        }
    }

    func testUnpackFixstrWithCompatibility() {
        let data: Data = [0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21]
        let packed: Data = [0xad] + data

        let unpacked = try? unpack(packed, compatibility: true)
        XCTAssertEqual(unpacked, MessagePackValue.Binary(data))
    }

    func testUnpackStr8WithCompatibility() {
        let data = Data(count: 0x20, repeatedValue: 0x00)
        let packed = [0xd9, 0x20] + data

        let unpacked = try? unpack(packed, compatibility: true)
        XCTAssertEqual(unpacked, MessagePackValue.Binary(data))
    }

    func testUnpackStr16WithCompatibility() {
        let data = Data(count: 0x1000, repeatedValue: 0x00)
        let packed = [0xda, 0x10, 0x00] + data

        let unpacked = try? unpack(packed, compatibility: true)
        XCTAssertEqual(unpacked, MessagePackValue.Binary(data))
    }

    func testUnpackStr32WithCompatibility() {
        let data = Data(count: 0x10000, repeatedValue: 0x00)
        let packed = [0xdb, 0x00, 0x01, 0x00, 0x00] + data

        let unpacked = try? unpack(packed, compatibility: true)
        XCTAssertEqual(unpacked, MessagePackValue.Binary(data))
    }
}
