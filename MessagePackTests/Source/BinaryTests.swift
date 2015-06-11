@testable import MessagePack
import XCTest

class BinaryTests: XCTestCase {
    let payload: Data = [0x00, 0x01, 0x02, 0x03, 0x04]
    let packed: Data = [0xc4, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04]

    func testPack() {
        XCTAssertEqual(pack(.Binary(payload)), packed)
    }

    func testUnpack() {
        do {
            let unpacked = try unpack(packed)
            XCTAssertEqual(unpacked, MessagePackValue.Binary(payload))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testPackBin16() {

    }

    func testUnpackBin16() {
        let data = [0xc4, 0xff] + Data(count: 0xff, repeatedValue: 0x00)
        let value = Data(count: 0xff, repeatedValue: 0x00)

        do {
            let unpacked = try unpack(data)
            XCTAssertEqual(unpacked, MessagePackValue.Binary(value))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testPackBin32() {
        let value = Data(count: 0x100, repeatedValue: 0x00)
        let expectedPacked = [0xc5, 0x01, 0x00] + Data(count: 0x100, repeatedValue: 0x00)
        XCTAssertEqual(pack(.Binary(value)), expectedPacked)
    }

    func testUnpackBin32() {
        let data =  [0xc5, 0x01, 0x00] + Data(count: 0x100, repeatedValue: 0x00)
        let value = Data(count: 0x100, repeatedValue: 0x00)

        do {
            let unpacked = try unpack(data)
            XCTAssertEqual(unpacked, MessagePackValue.Binary(value))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testPackBin64() {
        let value = Data(count: 0x1_0000, repeatedValue: 0x00)
        let expectedPacked = [0xc6, 0x00, 0x01, 0x00, 0x00] + value
        XCTAssertEqual(pack(.Binary(value)), expectedPacked)
    }

    func testUnpackBin64() {
        let data = [0xc6, 0x00, 0x01, 0x00, 0x00] + Data(count: 0x1_0000, repeatedValue: 0x00)
        let value = Data(count: 0x1_0000, repeatedValue: 0x00)

        do {
            let unpacked = try unpack(data)
            XCTAssertEqual(unpacked, MessagePackValue.Binary(value))
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
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
            } catch MessagePackError.InsufficientData {
            } catch {
                XCTFail("Expected MessagePackError.InsufficientData to be thrown")
            }
        }
    }
}
