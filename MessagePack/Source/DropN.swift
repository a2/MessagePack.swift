func dropFirstN<S: Sliceable where S.SubSlice == S>(s: S, n: S.Index.Distance) -> S {
    let end = advance(s.startIndex, n, s.endIndex)
    return s[s.startIndex..<end]
}

func dropLastN<S: Sliceable where S.SubSlice == S>(s: S, n: S.Index.Distance) -> S {
    let start = advance(s.endIndex, -n, s.startIndex)
    return s[start..<s.endIndex]
}
