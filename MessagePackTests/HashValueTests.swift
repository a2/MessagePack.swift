@testable import MessagePack
import XCTest

class HashValueTests: XCTestCase {
    func testNilHashValue() {
        XCTAssertEqual(MessagePackValue.Nil.hashValue, 0)
    }

    func testBoolHashValue() {
        XCTAssertEqual(MessagePackValue.Bool(true).hashValue, true.hashValue)
        XCTAssertEqual(MessagePackValue.Bool(false).hashValue, false.hashValue)
    }

    func testIntHashValue() {
        XCTAssertEqual(MessagePackValue.Int(-1).hashValue, Int64(-1).hashValue)
        XCTAssertEqual(MessagePackValue.Int(0).hashValue, Int64(0).hashValue)
        XCTAssertEqual(MessagePackValue.Int(1).hashValue, Int64(1).hashValue)
    }

    func testUIntHashValue() {
        XCTAssertEqual(MessagePackValue.UInt(0).hashValue, UInt64(0).hashValue)
        XCTAssertEqual(MessagePackValue.UInt(1).hashValue, UInt64(1).hashValue)
        XCTAssertEqual(MessagePackValue.UInt(2).hashValue, UInt64(2).hashValue)
    }

    func testFloatHashValue() {
        XCTAssertEqual(MessagePackValue.Float(0).hashValue, Float(0).hashValue)
        XCTAssertEqual(MessagePackValue.Float(1.618).hashValue, Float(1.618).hashValue)
        XCTAssertEqual(MessagePackValue.Float(3.14).hashValue, Float(3.14).hashValue)
    }

    func testDoubleHashValue() {
        XCTAssertEqual(MessagePackValue.Double(0).hashValue, Double(0).hashValue)
        XCTAssertEqual(MessagePackValue.Double(1.618).hashValue, Double(1.618).hashValue)
        XCTAssertEqual(MessagePackValue.Double(3.14).hashValue, Double(3.14).hashValue)
    }

    func testStringHashValue() {
        XCTAssertEqual(MessagePackValue.String("").hashValue, "".hashValue)
        XCTAssertEqual(MessagePackValue.String("MessagePack").hashValue, "MessagePack".hashValue)
    }

    func testBinaryHashValue() {
        XCTAssertEqual(MessagePackValue.Binary([]).hashValue, 0)
        XCTAssertEqual(MessagePackValue.Binary([0x00, 0x01, 0x02, 0x03, 0x04]).hashValue, 5)
    }

    func testArrayHashValue() {
        let values: [MessagePackValue] = [1, true, ""]
        XCTAssertEqual(MessagePackValue.Array(values).hashValue, 3)
    }

    func testMapHashValue() {
        let values: [MessagePackValue : MessagePackValue] = [
            "a": "apple",
            "b": "banana",
            "c": "cookie",
        ]
        XCTAssertEqual(MessagePackValue.Map(values).hashValue, 3)
    }

    func testExtendedHashValue() {
        XCTAssertEqual(MessagePackValue.Extended(5, []).hashValue, Int(5).hashValue ^ Int(0))
        XCTAssertEqual(MessagePackValue.Extended(5, [0x00, 0x01, 0x02, 0x03, 0x04]).hashValue, Int(5).hashValue ^ Int(5))
    }
}
