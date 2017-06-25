import Foundation
import XCTest
@testable import MessagePack

func map(_ count: Int) -> [MessagePackValue: MessagePackValue] {
    var dict = [MessagePackValue: MessagePackValue]()
    for i in 0 ..< Int64(count) {
        dict[.int(i)] = .nil
    }

    return dict
}

func payload(_ count: Int) -> Data {
    var data = Data()
    for i in 0 ..< Int64(count) {
        data.append(pack(.int(i)) + pack(.nil))
    }

    return data
}

func testPackMap(_ count: Int, prefix: Data) {
    let packed = pack(.map(map(count)))

    XCTAssertEqual(packed.subdata(in: 0 ..< prefix.count), prefix)

    var remainder = Subdata(data: packed, startIndex: prefix.count, endIndex: packed.count)
    var keys = Set<Int>()
    do {
        for _ in 0 ..< count {
            let value: MessagePackValue
            (value, remainder) = try unpack(remainder)
            let key = Int(value.integerValue!)

            XCTAssertFalse(keys.contains(key))
            keys.insert(key)

            let nilValue: MessagePackValue
            (nilValue, remainder) = try unpack(remainder)
            XCTAssertEqual(nilValue, MessagePackValue.nil)
        }
    } catch {
        print(error)
        XCTFail()
    }

    XCTAssertEqual(keys.count, count)
}

class MapTests: XCTestCase {
    static var allTests = {
        return [
            ("testLiteralConversion", testLiteralConversion),
            ("testPackFixmap", testPackFixmap),
            ("testUnpackFixmap", testUnpackFixmap),
            ("testPackMap16", testPackMap16),
            ("testUnpackMap16", testUnpackMap16),
        ]
    }()

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = ["c": "cookie"]
        XCTAssertEqual(implicitValue, MessagePackValue.map([.string("c"): .string("cookie")]))
    }

    func testPackFixmap() {
        let packed = Data([0x81, 0xa1, 0x63, 0xa6, 0x63, 0x6f, 0x6f, 0x6b, 0x69, 0x65])
        XCTAssertEqual(pack(.map([.string("c"): .string("cookie")])), packed)
    }

    func testUnpackFixmap() {
        let packed = Data([0x81, 0xa1, 0x63, 0xa6, 0x63, 0x6f, 0x6f, 0x6b, 0x69, 0x65])

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, MessagePackValue.map([.string("c"): .string("cookie")]))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackMap16() {
        testPackMap(16, prefix: Data([0xde, 0x00, 0x10]))
    }

    func testUnpackMap16() {
        let unpacked = try? unpack(Data([0xde, 0x00, 0x10]) + payload(16))
        XCTAssertEqual(unpacked?.value, MessagePackValue.map(map(16)))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }
}
