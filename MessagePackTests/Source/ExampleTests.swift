@testable import MessagePack
import XCTest

class ExampleTests: XCTestCase {
    let example: MessagePackValue = ["compact": true, "schema": 0]

    // Two possible "correct" values because dictionaries are unordered
    let correctA: Data = [0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00]
    let correctB: Data = [0x82, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3]

    func testPack() {
        let packed = pack(example)
        XCTAssertTrue(packed == correctA || packed == correctB)
    }

    func testUnpack() {
        do {
            let unpacked = try unpack(correctA)
            XCTAssertEqual(unpacked, example)
        } catch let error {
            XCTFail("Caught error: \(error)")
        }

        do {
            let unpacked = try unpack(correctB)
            XCTAssertEqual(unpacked, example)
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testInsufficientData() {
        do {
            try unpack([0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61])
            XCTFail("Expected unpack to throw")
        } catch MessagePackError.InsufficientData {
        } catch {
            XCTFail("Expected MessagePackError.InsufficientData to be thrown")
        }
    }

    func testUnpackNSData() {
        let data = correctA.withUnsafeBufferPointer { buffer in
            return NSData(bytes: buffer.baseAddress, length: buffer.count)
        }

        do {
            let unpacked = try unpack(data)
            XCTAssertEqual(unpacked, example)
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }

    func testUnpackDispatchData() {
        let data = correctA.withUnsafeBufferPointer { buffer in
            return dispatch_data_create(buffer.baseAddress, buffer.count, nil, nil)
        }

        do {
            let unpacked = try unpack(data)
            XCTAssertEqual(unpacked, example)
        } catch let error {
            XCTFail("Caught error: \(error)")
        }
    }
}
