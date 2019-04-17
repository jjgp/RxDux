import XCTest
@testable import RxDux

struct State {
    var message: String
}

enum Message {
    case message(String)
}

let middleware: Middleware<State> = { dispatch, getState in
    return { next in
        return { action in
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

final class RxDuxTests: XCTestCase {
    
    func testStoreInit() {
        let message = Store(reducer: reducer, middleware: [middleware])
            .getState()
            .message
        XCTAssertEqual(message, "foo")
    }
    
    func testStoreInitWithState() {
        let message = Store(reducer: reducer,
                            state: State(message: "baz"),
                            middleware: [middleware])
            .getState()
            .message
        XCTAssertEqual(message, "baz")
    }
    
    func testDispatchUpdatesState() {
        let store = Store(reducer: reducer,
                          middleware: [middleware])
        store.dispatch(Message.message("baz"))
        XCTAssertEqual(store.getState().message, "baz")
    }
    
    func testSubscriptionReceivesUpdates() {
        let store = Store(reducer: reducer,
                          middleware: [middleware])
        var message: String!
        let unsubscribe = store.subscribe {
            message = $0.message
        }
        XCTAssertEqual(message, "foo")
        store.dispatch(Message.message("baz"))
        XCTAssertEqual(message, "baz")
        unsubscribe()
    }
    
    func testSubscriptionUnsubscribe() {
        let store = Store(reducer: reducer,
                          middleware: [middleware])
        var message: String!
        let unsubscribe = store.subscribe {
            message = $0.message
        }
        XCTAssertEqual(message, "foo")
        unsubscribe()
        store.dispatch(Message.message("baz"))
        XCTAssertEqual(message, "foo")
    }
    
    func testBackgroundDispatch() {
        let store = Store(reducer: reducer,
                          middleware: [middleware])
        _ = store.subscribe {
            print($0)
        }
        
        DispatchQueue.global(qos: .background).async {
            store.dispatch(Message.message("baz"))
        }

        DispatchQueue.global(qos: .background).async {
            store.dispatch(Message.message("bar"))
        }
    }
    
    static var allTests = [
        ("testStoreInit", testStoreInit),
        ("testStoreInitWithState", testStoreInitWithState),
        ("testDispatchUpdatesState", testDispatchUpdatesState),
        ("testSubscriptionReceivesUpdates", testSubscriptionReceivesUpdates),
        ("testSubscriptionUnsubscribe", testSubscriptionUnsubscribe)
    ]
}
