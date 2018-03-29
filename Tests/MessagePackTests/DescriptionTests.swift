import Foundation
import XCTest
@testable import MessagePack

class DescriptionTests: XCTestCase {
    static var allTests = {
        return [
            ("testNilDescription", testNilDescription),
            ("testBoolDescription", testBoolDescription),
            ("testIntDescription", testIntDescription),
            ("testUIntDescription", testUIntDescription),
            ("testFloatDescription", testFloatDescription),
            ("testDoubleDescription", testDoubleDescription),
            ("testStringDescription", testStringDescription),
            ("testBinaryDescription", testBinaryDescription),
            ("testArrayDescription", testArrayDescription),
            ("testMapDescription", testMapDescription),
            ("testExtendedDescription", testExtendedDescription),
        ]
    }()

    func testNilDescription() {
        XCTAssertEqual(MessagePackValue.nil.description, "nil")
    }

    func testBoolDescription() {
        XCTAssertEqual(MessagePackValue.bool(true).description, "bool(true)")
        XCTAssertEqual(MessagePackValue.bool(false).description, "bool(false)")
    }

    func testIntDescription() {
        XCTAssertEqual(MessagePackValue.int(-1).description, "int(-1)")
        XCTAssertEqual(MessagePackValue.int(0).description, "int(0)")
        XCTAssertEqual(MessagePackValue.int(1).description, "int(1)")
    }

    func testUIntDescription() {
        XCTAssertEqual(MessagePackValue.uint(0).description, "uint(0)")
        XCTAssertEqual(MessagePackValue.uint(1).description, "uint(1)")
        XCTAssertEqual(MessagePackValue.uint(2).description, "uint(2)")
    }

    func testFloatDescription() {
        XCTAssertEqual(MessagePackValue.float(0.0).description, "float(0.0)")
        XCTAssertEqual(MessagePackValue.float(1.618).description, "float(1.618)")
        XCTAssertEqual(MessagePackValue.float(3.14).description, "float(3.14)")
    }

    func testDoubleDescription() {
        XCTAssertEqual(MessagePackValue.double(0.0).description, "double(0.0)")
        XCTAssertEqual(MessagePackValue.double(1.618).description, "double(1.618)")
        XCTAssertEqual(MessagePackValue.double(3.14).description, "double(3.14)")
    }

    func testStringDescription() {
        XCTAssertEqual(MessagePackValue.string("").description, "string()".description)
        XCTAssertEqual(MessagePackValue.string("MessagePack").description, "string(MessagePack)".description)
    }

    func testBinaryDescription() {
        XCTAssertEqual(MessagePackValue.binary(Data()).description, "data(0 bytes)")
        XCTAssertEqual(MessagePackValue.binary(Data(Data([0x00, 0x01, 0x02, 0x03, 0x04]))).description, "data(5 bytes)")
    }

    func testArrayDescription() {
        let values: [MessagePackValue] = [1, true, ""]
        XCTAssertEqual(MessagePackValue.array(values).description, "array([int(1), bool(true), string()])")
    }

    func testMapDescription() {
        let values: [MessagePackValue: MessagePackValue] = [
            "a": "apple",
            "b": "banana",
            "c": "cookie",
        ]

        let components = [
            "string(a): string(apple)",
            "string(b): string(banana)",
            "string(c): string(cookie)",
        ]

        let indexPermutations: [[Int]] = [
            [0, 1, 2],
            [0, 2, 1],
            [1, 0, 2],
            [1, 2, 0],
            [2, 0, 1],
            [2, 1, 0],
        ]

        let description = MessagePackValue.map(values).description

        var isValid = false
        for indices in indexPermutations {
            let permutation = indices.map { index in components[index] }
            let innerDescription = permutation.joined(separator: ", ")
            if description == "map([\(innerDescription)])" {
                isValid = true
                break
            }
        }

        XCTAssertTrue(isValid)
    }

    func testExtendedDescription() {
        XCTAssertEqual(MessagePackValue.extended(5, Data()).description, "extended(5, 0 bytes)")
        XCTAssertEqual(MessagePackValue.extended(5, Data([0x00, 0x10, 0x20, 0x30, 0x40])).description, "extended(5, 5 bytes)")
    }
}
