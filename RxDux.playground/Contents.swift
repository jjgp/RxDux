import RxDux

struct State {
    var message: String
}

enum Message {
    case message(String)
}

let middleware: Middleware<State> = { dispatch, getState in
    return { next in
        return { action in
            print(action)
            next(action)
        }
    }
}

let reducer: Reducer = { state, action -> State in
    var state = state ?? State(message: "foo")
    guard case let Message.message(message) = action else {
        return state
    }
    state.message = message
    return state
}

let store = Store(reducer: reducer, middleware: [middleware])
let unsubscribe = store.subscribe {
    let message = $0.message
    print(message)
}

store.getState().message
store.dispatch(Message.message("bar"))
store.getState().message
store.dispatch(Message.message("baz"))
store.getState().message
store.dispatch(Message.message("qux"))
store.getState().message
unsubscribe()
store.dispatch(Message.message("qux"))
store.getState().message
