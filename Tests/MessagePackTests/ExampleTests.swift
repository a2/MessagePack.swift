import Foundation
import XCTest
@testable import MessagePack

class ExampleTests: XCTestCase {
    static var allTests = {
        return [
            ("testPack", testPack),
            ("testUnpack", testUnpack),
            ("testUnpackInvalidData", testUnpackInvalidData),
            ("testUnpackInsufficientData", testUnpackInsufficientData),
        ]
    }()

    let example: MessagePackValue = ["compact": true, "schema": 0]

    // Two possible "correct" values because dictionaries are unordered
    let correctA = Data([0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00])
    let correctB = Data([0x82, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3])

    func testPack() {
        let packed = pack(example)
        XCTAssertTrue(packed == correctA || packed == correctB)
    }

    func testUnpack() {
        let unpacked1 = try? unpack(correctA)
        XCTAssertEqual(unpacked1?.value, example)
        XCTAssertEqual(unpacked1?.remainder.count, 0)

        let unpacked2 = try? unpack(correctB)
        XCTAssertEqual(unpacked2?.value, example)
        XCTAssertEqual(unpacked2?.remainder.count, 0)
    }

    func testUnpackInvalidData() {
        do {
            _ =  try unpack(Data([0xc1]))
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackError, .invalidData)
        }
    }

    func testUnpackInsufficientData() {
        do {
            var data = correctA
            data.removeLast()
            _ = try unpack(data)
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackError, .insufficientData)
        }
    }
}
