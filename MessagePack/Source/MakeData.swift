import Foundation

/**
    Creates a data object from the underlying storage of the array.

    :param: array An array to convert to data.

    :returns: A data object.
*/
func makeData(array: [UInt8]) -> NSData {
    return array.withUnsafeBufferPointer { (ptr: UnsafeBufferPointer<UInt8>) -> NSData in
        NSData(bytes: ptr.baseAddress, length: ptr.count)
    }
}

/**
    Creates a data object from the underlying storage of the contiguous array.

    :param: array A contiguous array to convert to data.

    :returns: A data object.
*/
func makeData(array: ContiguousArray<UInt8>) -> NSData {
    return array.withUnsafeBufferPointer { (ptr: UnsafeBufferPointer<UInt8>) -> NSData in
        NSData(bytes: ptr.baseAddress, length: ptr.count)
    }
}

/**
    Creates a data object from the underlying storage of the slice.

    :param: slice A slice to convert to data.

    :returns: A data object.
*/
func makeData(slice: Slice<UInt8>) -> NSData {
    return slice.withUnsafeBufferPointer { (ptr: UnsafeBufferPointer<UInt8>) -> NSData in
        NSData(bytes: ptr.baseAddress, length: ptr.count)
    }
}
