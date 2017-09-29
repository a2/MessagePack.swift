import Foundation
import XCTest
@testable import MessagePack

class ConveniencePropertiesTests: XCTestCase {
    static var allTests = {
        return [
            ("testCount", testCount),
            ("testIndexedSubscript", testIndexedSubscript),
            ("testKeyedSubscript", testKeyedSubscript),
            ("testIsNil", testIsNil),
            ("testIntegerValue", testIntegerValue),
            ("testUnsignedIntegerValue", testUnsignedIntegerValue),
            ("testArrayValue", testArrayValue),
            ("testBoolValue", testBoolValue),
            ("testFloatValue", testFloatValue),
            ("testDoubleValue", testDoubleValue),
            ("testStringValue", testStringValue),
            ("testStringValueWithCompatibility", testStringValueWithCompatibility),
            ("testDataValue", testDataValue),
            ("testExtendedValue", testExtendedValue),
            ("testExtendedType", testExtendedType),
            ("testMapValue    ", testMapValue    ),
        ]
    }()

    func testCount() {
        XCTAssert(MessagePackValue.array([0]).count == 1)
        XCTAssert(MessagePackValue.map(["c": "cookie"]).count == 1)
        XCTAssert(MessagePackValue.nil.count == nil)
    }

    func testIndexedSubscript() {
        XCTAssert(MessagePackValue.array([0])[0] == .uint(0))
        XCTAssert(MessagePackValue.array([0])[1] == nil)
        XCTAssert(MessagePackValue.nil[0] == nil)
    }

    func testKeyedSubscript() {
        XCTAssert(MessagePackValue.map(["c": "cookie"])["c"] == "cookie")
        XCTAssert(MessagePackValue.nil["c"] == nil)
    }

    func testIsNil() {
        XCTAssertTrue(MessagePackValue.nil.isNil)
        XCTAssertFalse(MessagePackValue.bool(true).isNil)
    }

    func testIntegerValue() {
        XCTAssert(MessagePackValue.int(-1).integerValue == -1)
        XCTAssert(MessagePackValue.uint(1).integerValue == 1)
        XCTAssert(MessagePackValue.nil.integerValue == nil)
    }

    func testUnsignedIntegerValue() {
        XCTAssert(MessagePackValue.int(-1).unsignedIntegerValue == nil)
        XCTAssert(MessagePackValue.int(1).unsignedIntegerValue == 1)
        XCTAssert(MessagePackValue.uint(1).unsignedIntegerValue == 1)
        XCTAssert(MessagePackValue.nil.unsignedIntegerValue == nil)
    }

    func testArrayValue() {
        let arrayValue = MessagePackValue.array([0]).arrayValue
        XCTAssertNotNil(arrayValue)
        XCTAssertEqual(arrayValue!, [0])
        XCTAssert(MessagePackValue.nil.arrayValue == nil)
    }

    func testBoolValue() {
        XCTAssert(MessagePackValue.bool(true).boolValue == true)
        XCTAssert(MessagePackValue.bool(false).boolValue == false)
        XCTAssert(MessagePackValue.nil.boolValue == nil)
    }

    func testFloatValue() {
        XCTAssert(MessagePackValue.nil.floatValue == nil)

        var floatValue = MessagePackValue.float(3.14).floatValue
        XCTAssertNotNil(floatValue)
        XCTAssertEqual(floatValue!, 3.14, accuracy: 0.0001)

        floatValue = MessagePackValue.double(3.14).floatValue
        XCTAssertNotNil(floatValue)
        XCTAssertEqual(floatValue!, 3.14, accuracy: 0.0001)
    }

    func testDoubleValue() {
        XCTAssert(MessagePackValue.nil.doubleValue == nil)

        var doubleValue = MessagePackValue.float(3.14).doubleValue
        XCTAssertNotNil(doubleValue)
        XCTAssertEqual(doubleValue!, 3.14, accuracy: 0.0001)

        doubleValue = MessagePackValue.double(3.14).doubleValue
        XCTAssertNotNil(doubleValue)
        XCTAssertEqual(doubleValue!, 3.14, accuracy: 0.0001)
    }

    func testStringValue() {
        XCTAssert(MessagePackValue.string("Hello, world!").stringValue == "Hello, world!")
        XCTAssert(MessagePackValue.nil.stringValue == nil)
    }

    func testStringValueWithCompatibility() {
        let stringValue = MessagePackValue.binary(Data([0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21])).stringValue
        XCTAssertEqual(stringValue, "Hello, world!")
    }

    func testDataValue() {
        XCTAssert(MessagePackValue.nil.dataValue == nil)

        var dataValue = MessagePackValue.binary(Data([0x00, 0x01, 0x02, 0x03, 0x04])).dataValue
        XCTAssertEqual(dataValue, Data([0x00, 0x01, 0x02, 0x03, 0x04]))

        dataValue = MessagePackValue.extended(4, Data([0x00, 0x01, 0x02, 0x03, 0x04])).dataValue
        XCTAssertEqual(dataValue, Data([0x00, 0x01, 0x02, 0x03, 0x04]))
    }

    func testExtendedValue() {
        XCTAssert(MessagePackValue.nil.extendedValue == nil)

        let extended = MessagePackValue.extended(4, Data([0x00, 0x01, 0x02, 0x03, 0x04]))
        let tuple = extended.extendedValue
        XCTAssertNotNil(tuple)

        let (type, data) = tuple!
        XCTAssertEqual(type, 4)
        XCTAssertEqual(data, Data([0x00, 0x01, 0x02, 0x03, 0x04]))
    }

    func testExtendedType() {
        XCTAssert(MessagePackValue.nil.extendedType == nil)

        let extended = MessagePackValue.extended(4, Data([0x00, 0x01, 0x02, 0x03, 0x04]))
        let type = extended.extendedType
        XCTAssertNotNil(type)
        XCTAssertEqual(type!, 4)
    }

    func testMapValue() {
        let dictionaryValue = MessagePackValue.map(["c": "cookie"]).dictionaryValue
        XCTAssertNotNil(dictionaryValue)
        XCTAssertEqual(dictionaryValue!, ["c": "cookie"])
        XCTAssert(MessagePackValue.nil.dictionaryValue == nil)
    }
}
