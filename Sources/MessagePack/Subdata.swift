import Foundation

public struct Subdata: RandomAccessCollection {
    let base: Data
    let baseStartIndex: Int
    let baseEndIndex: Int

    public init(data: Data, startIndex: Int = 0) {
        self.init(data: data, startIndex: startIndex, endIndex: data.endIndex)
    }

    public init(data: Data, startIndex: Int, endIndex: Int) {
        self.base = data
        self.baseStartIndex = startIndex
        self.baseEndIndex = endIndex
    }

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return baseEndIndex - baseStartIndex
    }

    public var count: Int {
        return endIndex - startIndex
    }

    public var isEmpty: Bool {
        return baseStartIndex == baseEndIndex
    }

    public subscript(index: Int) -> UInt8 {
        return base[baseStartIndex + index]
    }

    public func index(before i: Int) -> Int {
        return i - 1
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public subscript(bounds: Range<Int>) -> Subdata {
        precondition(baseStartIndex + bounds.upperBound <= baseEndIndex)
        return Subdata(data: base, startIndex: baseStartIndex + bounds.lowerBound, endIndex: baseStartIndex + bounds.upperBound)
    }

    public var data: Data {
        return base.subdata(in: baseStartIndex ..< baseEndIndex)
    }
}
