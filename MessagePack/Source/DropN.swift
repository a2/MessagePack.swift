/**
    Drops the first `n` elements from a slice.

    :param: s The slice from which to drop elements.
    :param: n The number of elements to drop.
    
    :returns: A subslice containing the same elements as `s`, less the first `n` values.
*/
func dropFirstN<S: Sliceable where S.SubSlice == S>(s: S, n: S.Index.Distance) -> S {
    let end = advance(s.startIndex, n, s.endIndex)
    return s[s.startIndex..<end]
}

/**
    Drops the last `n` elements from a slice.

    :param: s The slice from which to drop elements.
    :param: n The number of elements to drop.
    
    :returns: A subslice containing the same elements as `s`, less the last `n` values.
*/
func dropLastN<S: Sliceable where S.SubSlice == S>(s: S, n: S.Index.Distance) -> S {
    let start = advance(s.endIndex, -n, s.startIndex)
    return s[start..<s.endIndex]
}
