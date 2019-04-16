import RxSwift

struct State {
    let foobar: String
}

func accumulator(state: State, action: Any) -> State {
    return State(foobar: "barbaz")
}

let dispatch = PublishSubject<Any>()

let store = dispatch
    .scan(State(foobar: "foobar"), accumulator: accumulator)

let subscription = store.subscribe {
    if case let .next(foobar) = $0 {
        print(foobar)
    }
}

dispatch.onNext("action")
