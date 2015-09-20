@testable import MessagePack
import XCTest

class EqualityTests: XCTestCase {
    func testNilEqualToNil() {
        XCTAssertEqual(MessagePackValue.Nil, MessagePackValue.Nil)
    }

    func testNilNotEqualToBool() {
        XCTAssertNotEqual(MessagePackValue.Nil, MessagePackValue.Bool(false))
    }

    func testBoolEqualToBool() {
        XCTAssertEqual(MessagePackValue.Bool(true), MessagePackValue.Bool(true))
        XCTAssertEqual(MessagePackValue.Bool(false), MessagePackValue.Bool(false))
        XCTAssertNotEqual(MessagePackValue.Bool(true), MessagePackValue.Bool(false))
        XCTAssertNotEqual(MessagePackValue.Bool(false), MessagePackValue.Bool(true))
    }

    func testIntEqualToInt() {
        XCTAssertEqual(MessagePackValue.Int(1), MessagePackValue.Int(1))
    }

    func testUIntEqualToUInt() {
        XCTAssertEqual(MessagePackValue.UInt(1), MessagePackValue.UInt(1))
    }

    func testIntEqualToUInt() {
        XCTAssertEqual(MessagePackValue.Int(1), MessagePackValue.UInt(1))
    }

    func testUIntEqualToInt() {
        XCTAssertEqual(MessagePackValue.UInt(1), MessagePackValue.Int(1))
    }

    func testUIntNotEqualToInt() {
        XCTAssertNotEqual(MessagePackValue.UInt(1), MessagePackValue.Int(-1))
    }

    func testIntNotEqualToUInt() {
        XCTAssertNotEqual(MessagePackValue.Int(-1), MessagePackValue.UInt(1))
    }

    func testFloatEqualToFloat() {
        XCTAssertEqual(MessagePackValue.Float(3.14), MessagePackValue.Float(3.14))
    }

    func testDoubleEqualToDouble() {
        XCTAssertEqual(MessagePackValue.Double(3.14), MessagePackValue.Double(3.14))
    }

    func testFloatNotEqualToDouble() {
        XCTAssertNotEqual(MessagePackValue.Float(3.14), MessagePackValue.Double(3.14))
    }

    func testDoubleNotEqualToFloat() {
        XCTAssertNotEqual(MessagePackValue.Double(3.14), MessagePackValue.Float(3.14))
    }

    func testStringEqualToString() {
        XCTAssertEqual(MessagePackValue.String("Hello, world!"), MessagePackValue.String("Hello, world!"))
    }

    func testBinaryEqualToBinary() {
        XCTAssertEqual(MessagePackValue.Binary([0x00, 0x01, 0x02, 0x03, 0x04]), MessagePackValue.Binary([0x00, 0x01, 0x02, 0x03, 0x04]))
    }

    func testArrayEqualToArray() {
        XCTAssertEqual(MessagePackValue.Array([0, 1, 2, 3, 4]), MessagePackValue.Array([0, 1, 2, 3, 4]))
    }

    func testMapEqualToMap() {
        XCTAssertEqual(MessagePackValue.Map(["a": "apple", "b": "banana", "c": "cookie"]), MessagePackValue.Map(["b": "banana", "c": "cookie", "a": "apple"]))
    }

    func testExtendedEqualToExtended() {
        XCTAssertEqual(MessagePackValue.Extended(5, [0x00, 0x01, 0x02, 0x03, 0x04]), MessagePackValue.Extended(5, [0x00, 0x01, 0x02, 0x03, 0x04]))
    }
}