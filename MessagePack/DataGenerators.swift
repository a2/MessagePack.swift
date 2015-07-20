struct DispatchDataGenerator: GeneratorType {
    let data: dispatch_data_t
    var i: Int = 0

    var region: dispatch_data_t?
    var buffer: UnsafePointer<Byte>!
    var offset: Int!
    var size: Int!

    init(data: dispatch_data_t) {
        self.data = data
    }

    mutating func next() -> Byte? {
        if i >= dispatch_data_get_size(data) {
            return nil
        }

        if let offset = offset, size = size where i >= offset + size {
            region = nil
        }

        if region == nil {
            var subregionOffset: Int = 0
            let subregion = dispatch_data_copy_region(data, i, &subregionOffset)
            offset = subregionOffset

            var mapBuffer: UnsafePointer<Void> = nil
            var mapSize: Int = 0
            region = dispatch_data_create_map(subregion, &mapBuffer, &mapSize)
            buffer = UnsafePointer(mapBuffer)
            size = mapSize
        }

        return buffer[i++ - offset]
    }
}

struct NSDataGenerator: GeneratorType {
    let data: NSData
    var i: Int = 0

    var buffer: UnsafePointer<Byte>!
    var range: Range<Int>!

    init(data: NSData) {
        self.data = data
    }

    mutating func next() -> Byte? {
        if i >= data.length {
            return nil
        }

        if let range = range where range ~= i {
            buffer = nil
        }

        if buffer == nil {
            data.enumerateByteRangesUsingBlock { (bytes, byteRange, stop) in
                if let range = byteRange.toRange() where range ~= self.i {
                    self.buffer = UnsafePointer(bytes)
                    self.range = range
                    stop.memory = true
                }
            }
        }

        return buffer[i++ - range.startIndex]
    }
}
