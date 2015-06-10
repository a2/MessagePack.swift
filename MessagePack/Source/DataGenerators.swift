struct DispatchDataGenerator: GeneratorType {
    let data: dispatch_data_t
    var i: Int = 0

    var hasRegion = false
    var region: dispatch_data_t?
    var buffer: UnsafePointer<Byte>?
    var offset: Int?
    var size: Int?

    init(data: dispatch_data_t) {
        self.data = data
    }

    mutating func next() -> Byte? {
        if i >= dispatch_data_get_size(data) {
            return nil
        }

        if let offset = offset, size = size where i >= offset + size {
            hasRegion = false
        }

        if !hasRegion {
            var subregionOffset: Int = 0
            let subregion = dispatch_data_copy_region(data, i, &subregionOffset)
            offset = subregionOffset

            var mapBuffer: UnsafePointer<Void> = nil
            var mapSize: Int = 0
            region = dispatch_data_create_map(subregion, &mapBuffer, &mapSize)
            buffer = UnsafePointer(mapBuffer)
            size = mapSize
            hasRegion = true
        }

        if let buffer = buffer, offset = offset {
            return buffer[i++ - offset]
        } else {
            return nil
        }
    }
}

struct NSDataGenerator: GeneratorType {
    let data: NSData
    var i: Int = 0

    var hasBuffer = false
    var buffer: UnsafePointer<Byte>?
    var range: Range<Int>?

    init(data: NSData) {
        self.data = data
    }

    mutating func next() -> Byte? {
        if i >= data.length {
            return nil
        }

        if let range = range where range ~= i {
            hasBuffer = false
        }

        if !hasBuffer {
            data.enumerateByteRangesUsingBlock { (bytes, byteRange, stop) in
                if let range = byteRange.toRange() where range ~= self.i {
                    self.buffer = UnsafePointer(bytes)
                    self.range = range
                    self.hasBuffer = true
                    stop.memory = true
                }
            }
        }

        if let buffer = buffer, range = range {
            return buffer[i++ - range.startIndex]
        } else {
            return nil
        }
    }
}
