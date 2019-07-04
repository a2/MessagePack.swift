import Foundation
import XCTest
@testable import MessagePack

class BinaryTests: XCTestCase {
    static var allTests = {
        return [
            ("testPack", testPack),
            ("testUnpack", testUnpack),
            ("testPackBin16", testPackBin16),
            ("testUnpackBin16", testUnpackBin16),
            ("testPackBin32", testPackBin32),
            ("testUnpackBin32", testUnpackBin32),
            ("testPackBin64", testPackBin64),
            ("testUnpackBin64", testUnpackBin64),
            ("testUnpackInsufficientData", testUnpackInsufficientData),
            ("testUnpackFixstrWithCompatibility", testUnpackFixstrWithCompatibility),
            ("testUnpackStr8WithCompatibility", testUnpackStr8WithCompatibility),
            ("testUnpackStr16WithCompatibility", testUnpackStr16WithCompatibility),
            ("testUnpackStr32WithCompatibility", testUnpackStr32WithCompatibility),
        ]
    }()

    let payload = Data([0x00, 0x01, 0x02, 0x03, 0x04])
    let packed = Data([0xc4, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04])

    func testPack() {
        XCTAssertEqual(pack(.binary(payload)), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, .binary(payload))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackBinEmpty() {
        let value = Data()
        let expectedPacked = Data([0xc4, 0x00]) + value
        XCTAssertEqual(pack(.binary(value)), expectedPacked)
    }

    func testUnpackBinEmpty() {
        let data = Data()
        let packed = Data([0xc4, 0x00]) + data

        let unpacked = try? unpack(packed, compatibility: true)
        XCTAssertEqual(unpacked?.value, MessagePackValue.binary(data))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackBin16() {
        let value = Data(count: 0xff)
        let expectedPacked = Data([0xc4, 0xff]) + value
        XCTAssertEqual(pack(.binary(value)), expectedPacked)
    }

    func testUnpackBin16() {
        let data = Data([0xc4, 0xff]) + Data(count: 0xff)
        let value = Data(count: 0xff)

        let unpacked = try? unpack(data)
        XCTAssertEqual(unpacked?.value, .binary(value))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackBin32() {
        let value = Data(count: 0x100)
        let expectedPacked = Data([0xc5, 0x01, 0x00]) + value
        XCTAssertEqual(pack(.binary(value)), expectedPacked)
    }

    func testUnpackBin32() {
        let data = Data([0xc5, 0x01, 0x00]) + Data(count: 0x100)
        let value = Data(count: 0x100)

        let unpacked = try? unpack(data)
        XCTAssertEqual(unpacked?.value, .binary(value))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackBin64() {
        let value = Data(count: 0x1_0000)
        let expectedPacked = Data([0xc6, 0x00, 0x01, 0x00, 0x00]) + value
        XCTAssertEqual(pack(.binary(value)), expectedPacked)
    }

    func testUnpackBin64() {
        let data = Data([0xc6, 0x00, 0x01, 0x00, 0x00]) + Data(count: 0x1_0000)
        let value = Data(count: 0x1_0000)

        let unpacked = try? unpack(data)
        XCTAssertEqual(unpacked?.value, .binary(value))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testUnpackInsufficientData() {
        let dataArray: [Data] = [
            // only type byte
            Data([0xc4]), Data([0xc5]), Data([0xc6]),

            // type byte with no data
            Data([0xc4, 0x01]),
            Data([0xc5, 0x00, 0x01]),
            Data([0xc6, 0x00, 0x00, 0x00, 0x01]),
        ]

        for data in dataArray {
            do {
                _ = try unpack(data)
                XCTFail("Expected unpack to throw")
            } catch {
                XCTAssertEqual(error as? MessagePackError, .insufficientData)
            }
        }
    }

    func testUnpackFixstrWithCompatibility() {
        let data = Data([0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21])
        let packed = Data([0xad]) + data

        let unpacked = try? unpack(packed, compatibility: true)
        XCTAssertEqual(unpacked?.value, .binary(data))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testUnpackStr8WithCompatibility() {
        let data = Data(count: 0x20)
        let packed = Data([0xd9, 0x20]) + data

        let unpacked = try? unpack(packed, compatibility: true)
        XCTAssertEqual(unpacked?.value, .binary(data))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testUnpackStr16WithCompatibility() {
        let data = Data(count: 0x1000)
        let packed = Data([0xda, 0x10, 0x00]) + data

        let unpacked = try? unpack(packed, compatibility: true)
        XCTAssertEqual(unpacked?.value, .binary(data))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testUnpackStr32WithCompatibility() {
        let data = Data(count: 0x10000)
        let packed = Data([0xdb, 0x00, 0x01, 0x00, 0x00]) + data

        let unpacked = try? unpack(packed, compatibility: true)
        XCTAssertEqual(unpacked?.value, MessagePackValue.binary(data))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

}
