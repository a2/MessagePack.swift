import Nimble

func beContainedIn<S: SequenceType, T: Equatable where S.Generator.Element == T>(sequence: S) -> MatcherFunc<T> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "beContainedIn <\(stringify(sequence))>"
        if let value = actualExpression.evaluate() {
            return contains(sequence, value)
        } else {
            return false
        }
    }
}

func beContainedIn<S: SequenceType, L: BooleanType>(sequence: S, predicate: (S.Generator.Element, S.Generator.Element) -> L) -> MatcherFunc<S.Generator.Element> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "beContainedIn <\(stringify(sequence))>"
        if let value = actualExpression.evaluate() {
            return contains(sequence) { (element: S.Generator.Element) -> L in
                return predicate(value, element)
            }
        } else {
            return false
        }
    }
}
