@testable import MessagePack
import XCTest

class DescriptionTests: XCTestCase {
    func testNilDescription() {
        XCTAssertEqual(MessagePackValue.Nil.description, "Nil")
    }

    func testBoolDescription() {
        XCTAssertEqual(MessagePackValue.Bool(true).description, "Bool(true)")
        XCTAssertEqual(MessagePackValue.Bool(false).description, "Bool(false)")
    }

    func testIntDescription() {
        XCTAssertEqual(MessagePackValue.Int(-1).description, "Int(-1)")
        XCTAssertEqual(MessagePackValue.Int(0).description, "Int(0)")
        XCTAssertEqual(MessagePackValue.Int(1).description, "Int(1)")
    }

    func testUIntDescription() {
        XCTAssertEqual(MessagePackValue.UInt(0).description, "UInt(0)")
        XCTAssertEqual(MessagePackValue.UInt(1).description, "UInt(1)")
        XCTAssertEqual(MessagePackValue.UInt(2).description, "UInt(2)")
    }

    func testFloatDescription() {
        XCTAssertEqual(MessagePackValue.Float(0).description, "Float(0.0)")
        XCTAssertEqual(MessagePackValue.Float(1.618).description, "Float(1.618)")
        XCTAssertEqual(MessagePackValue.Float(3.14).description, "Float(3.14)")
    }

    func testDoubleDescription() {
        XCTAssertEqual(MessagePackValue.Double(0).description, "Double(0.0)")
        XCTAssertEqual(MessagePackValue.Double(1.618).description, "Double(1.618)")
        XCTAssertEqual(MessagePackValue.Double(3.14).description, "Double(3.14)")
    }

    func testStringDescription() {
        XCTAssertEqual(MessagePackValue.String("").description, "String()".description)
        XCTAssertEqual(MessagePackValue.String("MessagePack").description, "String(MessagePack)".description)
    }

    func testBinaryDescription() {
        let empty = makeData([])
        XCTAssertEqual(MessagePackValue.Binary(empty).description, "Data(<>)")

        let data = makeData([0x00, 0x01, 0x02, 0x03, 0x04])
        XCTAssertEqual(MessagePackValue.Binary(data).description, "Data(<00010203 04>)")
    }

    func testArrayDescription() {
        let values: [MessagePackValue] = [1, true, ""]
        XCTAssertEqual(MessagePackValue.Array(values).description, "Array([Int(1), Bool(true), String()])")
    }

    func testMapDescription() {
        let values: [MessagePackValue : MessagePackValue] = [
            "a": "apple",
            "b": "banana",
            "c": "cookie",
        ]

        let components = [
            "String(a): String(apple)",
            "String(b): String(banana)",
            "String(c): String(cookie)",
        ]

        let indexPermutations: [[Int]] = [
            [0, 1, 2],
            [0, 2, 1],
            [1, 0, 2],
            [1, 2, 0],
            [2, 0, 1],
            [2, 1, 0],
        ]

        let description = MessagePackValue.Map(values).description

        var isValid = false
        for indices in indexPermutations {
            let permutation = PermutationGenerator(elements: components, indices: indices)
            let innerDescription = ", ".join(permutation)
            if description == "Map([\(innerDescription)])" {
                isValid = true
                break
            }
        }

        XCTAssertTrue(isValid)
    }

    func testExtendedDescription() {
        let empty = makeData([])
        XCTAssertEqual(MessagePackValue.Extended(5, empty).description, "Extended(5, <>)")

        let data = makeData([0x00, 0x01, 0x02, 0x03, 0x04])
        XCTAssertEqual(MessagePackValue.Extended(5, data).description, "Extended(5, <00010203 04>)")
    }
}
