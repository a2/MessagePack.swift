import Foundation
import XCTest
@testable import MessagePack

class ExtendedTests: XCTestCase {
    static var allTests = {
        return [
            ("testPackFixext1", testPackFixext1),
            ("testUnpackFixext1", testUnpackFixext1),
            ("testPackFixext2", testPackFixext2),
            ("testUnpackFixext2", testUnpackFixext2),
            ("testPackFixext4", testPackFixext4),
            ("testUnpackFixext4", testUnpackFixext4),
            ("testPackFixext8", testPackFixext8),
            ("testUnpackFixext8", testUnpackFixext8),
            ("testPackFixext16", testPackFixext16),
            ("testUnpackFixext16", testUnpackFixext16),
            ("testPackExt8", testPackExt8),
            ("testUnpackExt8", testUnpackExt8),
            ("testPackExt16", testPackExt16),
            ("testUnpackExt16", testUnpackExt16),
            ("testPackExt32", testPackExt32),
            ("testUnpackExt32", testUnpackExt32),
            ("testUnpackInsufficientData", testUnpackInsufficientData),
        ]
    }()

    func testPackFixext1() {
        let value = MessagePackValue.extended(5, Data([0x00]))
        let packed = Data([0xd4, 0x05, 0x00])
        XCTAssertEqual(pack(value), packed)
    }

    func testUnpackFixext1() {
        let packed = Data([0xd4, 0x05, 0x00])
        let value = MessagePackValue.extended(5, Data([0x00]))

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, value)
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackFixext2() {
        let value = MessagePackValue.extended(5, Data([0x00, 0x01]))
        let packed = Data([0xd5, 0x05, 0x00, 0x01])
        XCTAssertEqual(pack(value), packed)
    }

    func testUnpackFixext2() {
        let packed = Data([0xd5, 0x05, 0x00, 0x01])
        let value = MessagePackValue.extended(5, Data([0x00, 0x01]))

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, value)
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackFixext4() {
        let value = MessagePackValue.extended(5, Data([0x00, 0x01, 0x02, 0x03]))
        let packed = Data([0xd6, 0x05, 0x00, 0x01, 0x02, 0x03])
        XCTAssertEqual(pack(value), packed)
    }

    func testUnpackFixext4() {
        let packed = Data([0xd6, 0x05, 0x00, 0x01, 0x02, 0x03])
        let value = MessagePackValue.extended(5, Data([0x00, 0x01, 0x02, 0x03]))

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, value)
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackFixext8() {
        let value = MessagePackValue.extended(5, Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]))
        let packed = Data([0xd7, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07])
        XCTAssertEqual(pack(value), packed)
    }

    func testUnpackFixext8() {
        let packed = Data([0xd7, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07])
        let value = MessagePackValue.extended(5, Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]))

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, value)
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackFixext16() {
        let value = MessagePackValue.extended(5, Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f]))
        let packed = Data([0xd8, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f])
        XCTAssertEqual(pack(value), packed)
    }

    func testUnpackFixext16() {
        let value = MessagePackValue.extended(5, Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f]))
        let packed = Data([0xd8, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f])

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, value)
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackExt8() {
        let payload = Data(count: 7)
        let value = MessagePackValue.extended(5, payload)
        XCTAssertEqual(pack(value), Data([0xc7, 0x07, 0x05]) + payload)
    }

    func testUnpackExt8() {
        let payload = Data(count: 7)
        let value = MessagePackValue.extended(5, payload)

        let unpacked = try? unpack(Data([0xc7, 0x07, 0x05]) + payload)
        XCTAssertEqual(unpacked?.value, value)
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackExt16() {
        let payload = Data(count: 0x100)
        let value = MessagePackValue.extended(5, payload)
        XCTAssertEqual(pack(value), Data([0xc8, 0x01, 0x00, 0x05]) + payload)
    }

    func testUnpackExt16() {
        let payload = Data(count: 0x100)
        let value = MessagePackValue.extended(5, payload)

        let unpacked = try? unpack(Data([0xc8, 0x01, 0x00, 0x05]) + payload)
        XCTAssertEqual(unpacked?.value, value)
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackExt32() {
        let payload = Data(count: 0x10000)
        let value = MessagePackValue.extended(5, payload)
        XCTAssertEqual(pack(value), Data([0xc9, 0x00, 0x01, 0x00, 0x00, 0x05]) + payload)
    }

    func testUnpackExt32() {
        let payload = Data(count: 0x10000)
        let value = MessagePackValue.extended(5, payload)

        let unpacked = try? unpack(Data([0xc9, 0x00, 0x01, 0x00, 0x00, 0x05]) + payload)
        XCTAssertEqual(unpacked?.value, value)
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testUnpackInsufficientData() {
        let dataArray: [Data] = [
            // fixent
            Data([0xd4]), Data([0xd5]), Data([0xd6]), Data([0xd7]), Data([0xd8]),

            // ext 8, 16, 32
            Data([0xc7]), Data([0xc8]), Data([0xc9])
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
}
