@testable import MessagePack
import XCTest

class MapTests: XCTestCase {
    func testLiteralConversion() {
        let implicitValue: MessagePackValue = ["c": "cookie"]
        XCTAssertEqual(implicitValue, MessagePackValue.Map([.String("c"): .String("cookie")]))
    }

    func testPackFixmap() {
        let packed = makeData([0x81, 0xa1, 0x63, 0xa6, 0x63, 0x6f, 0x6f, 0x6b, 0x69, 0x65])
        XCTAssertEqual(pack(.Map([.String("c"): .String("cookie")])), packed)
    }

    func testUnpackFixmap() {
        let packed = makeData([0x81, 0xa1, 0x63, 0xa6, 0x63, 0x6f, 0x6f, 0x6b, 0x69, 0x65])
        let unpacked = unpack(packed)
        XCTAssertTrue(unpacked != nil)

        XCTAssertEqual(unpacked!, MessagePackValue.Map([.String("c"): .String("cookie")]))
    }

    func map(count: Int) -> [MessagePackValue : MessagePackValue] {
        var dict = [MessagePackValue : MessagePackValue]()
        for i in 0..<count {
            dict[.Int(numericCast(i))] = .Nil
        }

        return dict
    }

    func payload(count: Int) -> NSData {
        let data = NSMutableData()
        for i in 0..<count {
            data.appendData(pack(.Int(numericCast(i))))
            data.appendData(pack(.Nil))
        }
        
        return data
    }

    func testPackMap16() {
        let packed = pack(.Map(map(16)))
        let bufferPtr = UnsafeBufferPointer(start: UnsafePointer<UInt8>(packed.bytes), count: packed.length)
        var generator = bufferPtr.generate()

        let bytes: [UInt8] = [0xde, 0x00, 0x10]
        for byte in bytes {
            if let next = generator.next() {
                XCTAssertEqual(next, byte)
            } else {
                XCTFail("Generator yielded nil element")
            }
        }

        var elementIsKey = true
        var keys = Set<Int>()
        while let value = unpack(&generator) {
            if elementIsKey {
                let intValue: Int!
                switch value {
                case .Int(let int64Value):
                    intValue = numericCast(int64Value) as Int
                case .UInt(let uint64Value):
                    intValue = numericCast(uint64Value) as Int
                default:
                    XCTFail("Expected integer-convertible value; got: \(value)")
                    intValue = nil
                }

                XCTAssertFalse(keys.contains(intValue))
                keys.insert(intValue)
            } else {
                XCTAssertEqual(value, MessagePackValue.Nil)
            }

            elementIsKey = !elementIsKey
        }

        XCTAssertEqual(keys.count, 16)
    }

    func testUnpackMap16() {
        let packed = NSMutableData()
        packed.appendData(makeData([0xde, 0x00, 0x10]))
        packed.appendData(payload(16))

        let unpacked = unpack(packed)
        XCTAssertTrue(unpacked != nil)

        let value = map(16)
        XCTAssertEqual(unpacked!, MessagePackValue.Map(value))
    }

    func testPackMap32() {
        let packed = pack(.Map(map(0x1_0000)))
        let bufferPtr = UnsafeBufferPointer(start: UnsafePointer<UInt8>(packed.bytes), count: packed.length)
        var generator = bufferPtr.generate()

        let bytes: [UInt8] = [0xdf, 0x00, 0x01, 0x00, 0x00]
        for byte in bytes {
            if let next = generator.next() {
                XCTAssertEqual(next, byte)
            } else {
                XCTFail("Generator yielded nil element")
            }
        }

        var elementIsKey = true
        var keys = Set<Int>()
        while let value = unpack(&generator) {
            if elementIsKey {
                let intValue: Int!
                switch value {
                case .Int(let int64Value):
                    intValue = numericCast(int64Value) as Int
                case .UInt(let uint64Value):
                    intValue = numericCast(uint64Value) as Int
                default:
                    XCTFail("Expected integer-convertible value; got: \(value)")
                    intValue = nil
                }

                XCTAssertFalse(keys.contains(intValue))
                keys.insert(intValue)
            } else {
                XCTAssertEqual(value, MessagePackValue.Nil)
            }

            elementIsKey = !elementIsKey
        }

        XCTAssertEqual(keys.count, 0x1_0000)
    }

    func testUnpackMap32() {
        let packed = NSMutableData()
        packed.appendData(makeData([0xdf, 0x00, 0x01, 0x00, 0x00]))
        packed.appendData(payload(0x1_0000))

        let unpacked = unpack(packed)
        XCTAssertTrue(unpacked != nil)

        let value = map(0x1_0000)
        XCTAssertEqual(unpacked!, MessagePackValue.Map(value))
    }
}
