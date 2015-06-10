@testable import MessagePack
import XCTest

class ExampleTests: XCTestCase {

    let example: MessagePackValue = ["compact": true, "schema": 0]

    // Two possible "correct" values because dictionaries are unordered
    let correctA = makeData([0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00])
    let correctB = makeData([0x82, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3])

    func testPack() {
        let packed = pack(example)
        XCTAssertTrue(packed == correctA || packed == correctB)
    }

    func testUnpack() {
        let unpackedA = unpack(correctA)
        XCTAssert(unpackedA != nil)
        XCTAssertEqual(unpackedA!, example)

        let unpackedB = unpack(correctB)
        XCTAssert(unpackedB != nil)
        XCTAssertEqual(unpackedB!, example)
    }
}
