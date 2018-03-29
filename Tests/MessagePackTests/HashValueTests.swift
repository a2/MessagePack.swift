import Foundation
import XCTest
@testable import MessagePack

class HashValueTests: XCTestCase {
    static var allTests = {
        return [
            ("testNilHashValue", testNilHashValue),
            ("testBoolHashValue", testBoolHashValue),
            ("testIntHashValue", testIntHashValue),
            ("testUIntHashValue", testUIntHashValue),
            ("testFloatHashValue", testFloatHashValue),
            ("testDoubleHashValue", testDoubleHashValue),
            ("testStringHashValue", testStringHashValue),
            ("testBinaryHashValue", testBinaryHashValue),
            ("testArrayHashValue", testArrayHashValue),
            ("testMapHashValue", testMapHashValue),
            ("testExtendedHashValue", testExtendedHashValue),
        ]
    }()

    func testNilHashValue() {
        XCTAssertEqual(MessagePackValue.nil.hashValue, 0)
    }

    func testBoolHashValue() {
        XCTAssertEqual(MessagePackValue.bool(true).hashValue, true.hashValue)
        XCTAssertEqual(MessagePackValue.bool(false).hashValue, false.hashValue)
    }

    func testIntHashValue() {
        XCTAssertEqual(MessagePackValue.int(-1).hashValue, Int64(-1).hashValue)
        XCTAssertEqual(MessagePackValue.int(0).hashValue, Int64(0).hashValue)
        XCTAssertEqual(MessagePackValue.int(1).hashValue, Int64(1).hashValue)
    }

    func testUIntHashValue() {
        XCTAssertEqual(MessagePackValue.uint(0).hashValue, UInt64(0).hashValue)
        XCTAssertEqual(MessagePackValue.uint(1).hashValue, UInt64(1).hashValue)
        XCTAssertEqual(MessagePackValue.uint(2).hashValue, UInt64(2).hashValue)
    }

    func testFloatHashValue() {
        XCTAssertEqual(MessagePackValue.float(0).hashValue, Float(0).hashValue)
        XCTAssertEqual(MessagePackValue.float(1.618).hashValue, Float(1.618).hashValue)
        XCTAssertEqual(MessagePackValue.float(3.14).hashValue, Float(3.14).hashValue)
    }

    func testDoubleHashValue() {
        XCTAssertEqual(MessagePackValue.double(0).hashValue, Double(0).hashValue)
        XCTAssertEqual(MessagePackValue.double(1.618).hashValue, Double(1.618).hashValue)
        XCTAssertEqual(MessagePackValue.double(3.14).hashValue, Double(3.14).hashValue)
    }

    func testStringHashValue() {
        XCTAssertEqual(MessagePackValue.string("").hashValue, "".hashValue)
        XCTAssertEqual(MessagePackValue.string("MessagePack").hashValue, "MessagePack".hashValue)
    }

    func testBinaryHashValue() {
        XCTAssertEqual(MessagePackValue.binary(Data()).hashValue, 0)
        XCTAssertEqual(MessagePackValue.binary(Data([0x00, 0x01, 0x02, 0x03, 0x04])).hashValue, 5)
    }

    func testArrayHashValue() {
        let values: [MessagePackValue] = [1, true, ""]
        XCTAssertEqual(MessagePackValue.array(values).hashValue, 3)
    }

    func testMapHashValue() {
        let values: [MessagePackValue: MessagePackValue] = [
            "a": "apple",
            "b": "banana",
            "c": "cookie",
        ]
        XCTAssertEqual(MessagePackValue.map(values).hashValue, 3)
    }

    func testExtendedHashValue() {
        XCTAssertEqual(MessagePackValue.extended(5, Data()).hashValue, Int(5).hashValue * 31 + Int(0))
        XCTAssertEqual(MessagePackValue.extended(5, Data([0x00, 0x01, 0x02, 0x03, 0x04])).hashValue, Int(5).hashValue * 31 + Int(5))
    }
}
