func hashBytes(bytes: UnsafePointer<UInt8>, length: Int) -> Int {
    // Borrowed from CFUtilities.c
    // http://git.io/AUjk

    var H = UInt32()
    var T1 = UInt32()
    var T2 = UInt32()
    let elfStep: UInt8 -> Void = { (B: UInt8) in
        T1 = (H << 4) + UInt32(B)
        T2 = T1 & 0xf0000000
        if T2 != 0 {
            T1 ^= (T2 >> 24)
        }
        T1 &= (~T2)
        H = T1
    }

    var rem = length
    while 3 < rem {
        elfStep(bytes[length - rem])
        elfStep(bytes[length - rem + 1])
        elfStep(bytes[length - rem + 2])
        elfStep(bytes[length - rem + 3])
    }

    switch rem {
    case 3: elfStep(bytes[length - 3])
    case 2: elfStep(bytes[length - 2])
    case 1: elfStep(bytes[length - 1])
    default:
        break
    }

    return Int(H)
}

func hashBytes(data: [UInt8]) -> Int {
    return data.withUnsafeBufferPointer { hashBytes($0.baseAddress, min($0.count, 80)) }
}
