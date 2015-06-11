@testable import MessagePack
import XCTest

class ConveniencePropertiesTests: XCTestCase {
    func testCount() {
        XCTAssert(MessagePackValue.Array([0]).count == 1)
        XCTAssert(MessagePackValue.Map(["c": "cookie"]).count == 1)
        XCTAssert(MessagePackValue.Nil.count == nil)
    }

    func testIndexedSubscript() {
        XCTAssert(MessagePackValue.Array([0])[0] == .UInt(0))
        XCTAssert(MessagePackValue.Array([0])[1] == nil)
        XCTAssert(MessagePackValue.Nil[0] == nil)
    }

    func testKeyedSubscript() {
        XCTAssert(MessagePackValue.Map(["c": "cookie"])["c"] == "cookie")
        XCTAssert(MessagePackValue.Nil["c"] == nil)
    }

    func testIsNil() {
        XCTAssertTrue(MessagePackValue.Nil.isNil)
        XCTAssertFalse(MessagePackValue.Bool(true).isNil)
    }

    func testIntegerValue() {
        XCTAssert(MessagePackValue.Int(-1).integerValue == -1)
        XCTAssert(MessagePackValue.UInt(1).integerValue == 1)
        XCTAssert(MessagePackValue.Nil.integerValue == nil)
    }

    func testUnsignedIntegerValue() {
        XCTAssert(MessagePackValue.Int(-1).unsignedIntegerValue == nil)
        XCTAssert(MessagePackValue.Int(1).unsignedIntegerValue == 1)
        XCTAssert(MessagePackValue.UInt(1).unsignedIntegerValue == 1)
        XCTAssert(MessagePackValue.Nil.unsignedIntegerValue == nil)
    }

    func testArrayValue() {
        let arrayValue = MessagePackValue.Array([0]).arrayValue
        XCTAssert(arrayValue != nil)
        XCTAssertEqual(arrayValue!, [0])
        XCTAssert(MessagePackValue.Nil.arrayValue == nil)
    }

    func testBoolValue() {
        XCTAssert(MessagePackValue.Bool(true).boolValue == true)
        XCTAssert(MessagePackValue.Bool(false).boolValue == false)
        XCTAssert(MessagePackValue.Nil.boolValue == nil)
    }

    func testFloatValue() {
        XCTAssert(MessagePackValue.Nil.floatValue == nil)

        var floatValue = MessagePackValue.Float(3.14).floatValue
        XCTAssert(floatValue != nil)
        XCTAssertEqualWithAccuracy(floatValue!, 3.14, accuracy: 0.0001)

        floatValue = MessagePackValue.Double(3.14).floatValue
        XCTAssert(floatValue != nil)
        XCTAssertEqualWithAccuracy(floatValue!, 3.14, accuracy: 0.0001)
    }

    func testDoubleValue() {
        XCTAssert(MessagePackValue.Nil.doubleValue == nil)

        var doubleValue = MessagePackValue.Float(3.14).doubleValue
        XCTAssert(doubleValue != nil)
        XCTAssertEqualWithAccuracy(doubleValue!, 3.14, accuracy: 0.0001)

        doubleValue = MessagePackValue.Double(3.14).doubleValue
        XCTAssert(doubleValue != nil)
        XCTAssertEqualWithAccuracy(doubleValue!, 3.14, accuracy: 0.0001)
    }

    func testStringValue() {
        XCTAssert(MessagePackValue.String("Hello, world!").stringValue == "Hello, world!")
        XCTAssert(MessagePackValue.Nil.stringValue == nil)
    }

    func testDataValue() {
        XCTAssert(MessagePackValue.Nil.dataValue == nil)

        var dataValue = MessagePackValue.Binary([0x00, 0x01, 0x02, 0x03, 0x04]).dataValue
        XCTAssert(dataValue != nil)
        XCTAssertEqual(dataValue!, [0x00, 0x01, 0x02, 0x03, 0x04])

        dataValue = MessagePackValue.Extended(4, [0x00, 0x01, 0x02, 0x03, 0x04]).dataValue
        XCTAssert(dataValue != nil)
        XCTAssertEqual(dataValue!, [0x00, 0x01, 0x02, 0x03, 0x04])
    }

    func testExtendedValue() {
        XCTAssert(MessagePackValue.Nil.extendedValue == nil)

        let extended = MessagePackValue.Extended(4, [0x00, 0x01, 0x02, 0x03, 0x04])
        let tuple = extended.extendedValue
        XCTAssert(tuple != nil)

        let (type, data) = tuple!
        XCTAssertEqual(type, 4)
        XCTAssertEqual(data, [0x00, 0x01, 0x02, 0x03, 0x04])
    }

    func testExtendedType() {
        XCTAssert(MessagePackValue.Nil.extendedType == nil)

        let extended = MessagePackValue.Extended(4, [0x00, 0x01, 0x02, 0x03, 0x04])
        let type = extended.extendedType
        XCTAssert(type != nil)
        XCTAssertEqual(type!, 4)
    }

    func testMapValue() {
        let dictionaryValue = MessagePackValue.Map(["c": "cookie"]).dictionaryValue
        XCTAssert(dictionaryValue != nil)
        XCTAssertEqual(dictionaryValue!, ["c": "cookie"])
        XCTAssert(MessagePackValue.Nil.dictionaryValue == nil)
    }
}
