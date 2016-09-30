import Foundation
import XCTest
@testable import MessagePack

class EqualityTests: XCTestCase {
    static var allTests = {
        return [
            ("testNilEqualToNil", testNilEqualToNil),
            ("testNilNotEqualToBool", testNilNotEqualToBool),
            ("testBoolEqualToBool", testBoolEqualToBool),
            ("testIntEqualToInt", testIntEqualToInt),
            ("testUIntEqualToUInt", testUIntEqualToUInt),
            ("testIntEqualToUInt", testIntEqualToUInt),
            ("testUIntEqualToInt", testUIntEqualToInt),
            ("testUIntNotEqualToInt", testUIntNotEqualToInt),
            ("testIntNotEqualToUInt", testIntNotEqualToUInt),
            ("testFloatEqualToFloat", testFloatEqualToFloat),
            ("testDoubleEqualToDouble", testDoubleEqualToDouble),
            ("testFloatNotEqualToDouble", testFloatNotEqualToDouble),
            ("testDoubleNotEqualToFloat", testDoubleNotEqualToFloat),
            ("testStringEqualToString", testStringEqualToString),
            ("testBinaryEqualToBinary", testBinaryEqualToBinary),
            ("testArrayEqualToArray", testArrayEqualToArray),
            ("testMapEqualToMap", testMapEqualToMap),
            ("testExtendedEqualToExtended", testExtendedEqualToExtended),
        ]
    }()

    func testNilEqualToNil() {
        XCTAssertEqual(MessagePackValue.nil, MessagePackValue.nil)
    }

    func testNilNotEqualToBool() {
        XCTAssertNotEqual(MessagePackValue.nil, MessagePackValue.bool(false))
    }

    func testBoolEqualToBool() {
        XCTAssertEqual(MessagePackValue.bool(true), MessagePackValue.bool(true))
        XCTAssertEqual(MessagePackValue.bool(false), MessagePackValue.bool(false))
        XCTAssertNotEqual(MessagePackValue.bool(true), MessagePackValue.bool(false))
        XCTAssertNotEqual(MessagePackValue.bool(false), MessagePackValue.bool(true))
    }

    func testIntEqualToInt() {
        XCTAssertEqual(MessagePackValue.int(1), MessagePackValue.int(1))
    }

    func testUIntEqualToUInt() {
        XCTAssertEqual(MessagePackValue.uint(1), MessagePackValue.uint(1))
    }

    func testIntEqualToUInt() {
        XCTAssertEqual(MessagePackValue.int(1), MessagePackValue.uint(1))
    }

    func testUIntEqualToInt() {
        XCTAssertEqual(MessagePackValue.uint(1), MessagePackValue.int(1))
    }

    func testUIntNotEqualToInt() {
        XCTAssertNotEqual(MessagePackValue.uint(1), MessagePackValue.int(-1))
    }

    func testIntNotEqualToUInt() {
        XCTAssertNotEqual(MessagePackValue.int(-1), MessagePackValue.uint(1))
    }

    func testFloatEqualToFloat() {
        XCTAssertEqual(MessagePackValue.float(3.14), MessagePackValue.float(3.14))
    }

    func testDoubleEqualToDouble() {
        XCTAssertEqual(MessagePackValue.double(3.14), MessagePackValue.double(3.14))
    }

    func testFloatNotEqualToDouble() {
        XCTAssertNotEqual(MessagePackValue.float(3.14), MessagePackValue.double(3.14))
    }

    func testDoubleNotEqualToFloat() {
        XCTAssertNotEqual(MessagePackValue.double(3.14), MessagePackValue.float(3.14))
    }

    func testStringEqualToString() {
        XCTAssertEqual(MessagePackValue.string("Hello, world!"), MessagePackValue.string("Hello, world!"))
    }

    func testBinaryEqualToBinary() {
        XCTAssertEqual(MessagePackValue.binary(Data([0x00, 0x01, 0x02, 0x03, 0x04])), MessagePackValue.binary(Data([0x00, 0x01, 0x02, 0x03, 0x04])))
    }

    func testArrayEqualToArray() {
        XCTAssertEqual(MessagePackValue.array([0, 1, 2, 3, 4]), MessagePackValue.array([0, 1, 2, 3, 4]))
    }

    func testMapEqualToMap() {
        XCTAssertEqual(MessagePackValue.map(["a": "apple", "b": "banana", "c": "cookie"]), MessagePackValue.map(["b": "banana", "c": "cookie", "a": "apple"]))
    }

    func testExtendedEqualToExtended() {
        XCTAssertEqual(MessagePackValue.extended(5, Data([0x00, 0x01, 0x02, 0x03, 0x04])), MessagePackValue.extended(5, Data([0x00, 0x01, 0x02, 0x03, 0x04])))
    }
}
