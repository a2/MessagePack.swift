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
            ("testIntValue", testIntValue),
            ("testInt8Value", testInt8Value),
            ("testInt16Value", testInt16Value),
            ("testIn32Value", testInt32Value),
            ("testInt64Value", testInt64Value),
            ("testUIntValue", testUIntValue),
            ("testUInt8Value", testUInt8Value),
            ("testUInt16Value", testUInt16Value),
            ("testUInt32Value", testUInt32Value),
            ("testUInt64Value", testUInt64Value),
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

    func testIntValue() {
        XCTAssert(MessagePackValue.int(-1).intValue == -1)
        XCTAssert(MessagePackValue.uint(1).intValue == 1)
        XCTAssertNil(MessagePackValue.nil.intValue)
    }

    func testInt8Value() {
        XCTAssert(MessagePackValue.int(-1).int8Value == -1)
        XCTAssert(MessagePackValue.int(1).int8Value == 1)
        XCTAssertNil(MessagePackValue.int(Int64(Int8.min) - 1).int8Value)
        XCTAssertNil(MessagePackValue.int(Int64(Int8.max) + 1).int8Value)

        XCTAssert(MessagePackValue.uint(1).int8Value == 1)
        XCTAssertNil(MessagePackValue.uint(UInt64(Int8.max) + 1).int8Value)
        XCTAssertNil(MessagePackValue.nil.int8Value)
    }

    func testInt16Value() {
        XCTAssert(MessagePackValue.int(-1).int16Value == -1)
        XCTAssert(MessagePackValue.int(1).int16Value == 1)
        XCTAssertNil(MessagePackValue.int(Int64(Int16.min) - 1).int16Value)
        XCTAssertNil(MessagePackValue.int(Int64(Int16.max) + 1).int16Value)

        XCTAssert(MessagePackValue.uint(1).int16Value == 1)
        XCTAssertNil(MessagePackValue.uint(UInt64(Int16.max) + 1).int16Value)
        XCTAssertNil(MessagePackValue.nil.int16Value)
    }

    func testInt32Value() {
        XCTAssert(MessagePackValue.int(-1).int32Value == -1)
        XCTAssert(MessagePackValue.int(1).int32Value == 1)
        XCTAssertNil(MessagePackValue.int(Int64(Int32.min) - 1).int32Value)
        XCTAssertNil(MessagePackValue.int(Int64(Int32.max) + 1).int32Value)

        XCTAssert(MessagePackValue.uint(1).int32Value == 1)
        XCTAssertNil(MessagePackValue.uint(UInt64(Int32.max) + 1).int32Value)
        XCTAssertNil(MessagePackValue.nil.int32Value)
    }

    func testInt64Value() {
        XCTAssert(MessagePackValue.int(-1).int64Value == -1)
        XCTAssert(MessagePackValue.int(1).int64Value == 1)

        XCTAssert(MessagePackValue.uint(1).int64Value == 1)
        XCTAssertNil(MessagePackValue.uint(UInt64(Int64.max) + 1).int64Value)
        XCTAssertNil(MessagePackValue.nil.int64Value)
    }

    func testUIntValue() {
        XCTAssert(MessagePackValue.uint(1).uintValue == 1)

        XCTAssertNil(MessagePackValue.int(-1).uintValue)
        XCTAssert(MessagePackValue.int(1).uintValue == 1)
        XCTAssertNil(MessagePackValue.nil.uintValue)
    }

    func testUInt8Value() {
        XCTAssert(MessagePackValue.uint(1).uint8Value == 1)
        XCTAssertNil(MessagePackValue.uint(UInt64(UInt8.max) + 1).uint8Value)

        XCTAssertNil(MessagePackValue.int(-1).uint8Value)
        XCTAssert(MessagePackValue.int(1).uint8Value == 1)
        XCTAssertNil(MessagePackValue.int(Int64(UInt8.max) + 1).uint8Value)
        XCTAssertNil(MessagePackValue.nil.uint8Value)
    }

    func testUInt16Value() {
        XCTAssert(MessagePackValue.uint(1).uint16Value == 1)
        XCTAssertNil(MessagePackValue.uint(UInt64(UInt16.max) + 1).uint16Value)

        XCTAssertNil(MessagePackValue.int(-1).uint16Value)
        XCTAssert(MessagePackValue.int(1).uint16Value == 1)
        XCTAssertNil(MessagePackValue.int(Int64(UInt16.max) + 1).uint16Value)
        XCTAssertNil(MessagePackValue.nil.uint16Value)
    }

    func testUInt32Value() {
        XCTAssert(MessagePackValue.uint(1).uint32Value == 1)
        XCTAssertNil(MessagePackValue.uint(UInt64(UInt32.max) + 1).uint32Value)

        XCTAssertNil(MessagePackValue.int(-1).uint32Value)
        XCTAssert(MessagePackValue.int(1).uint32Value == 1)
        XCTAssertNil(MessagePackValue.int(Int64(UInt32.max) + 1).uint32Value)
        XCTAssertNil(MessagePackValue.nil.uint32Value)
    }

    func testUInt64Value() {
        XCTAssert(MessagePackValue.uint(1).uint64Value == 1)

        XCTAssertNil(MessagePackValue.int(-1).uint64Value)
        XCTAssert(MessagePackValue.int(1).uint64Value == 1)
        XCTAssertNil(MessagePackValue.nil.uint8Value)
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
        XCTAssertNil(floatValue)
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
