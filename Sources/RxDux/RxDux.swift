import Foundation
import RxSwift

public typealias Action = Any

public typealias Dispatch = (Action) -> Void

public typealias GetState<State> = () -> State

public typealias Middleware<State> = (@escaping Dispatch, @escaping GetState<State>)
    -> (@escaping Dispatch) -> Dispatch

public typealias Reducer<State> = (_ state: State?, _ action: Action) -> State

public class Store<State> {
    
    public private(set) var dispatch: Dispatch
    
    private let disposeBag = DisposeBag()
    
    public let getState: GetState<State>
    
    public private(set) var observable: Observable<State>
    
    public init(reducer: @escaping Reducer<State>,
                state: State? = nil,
                middleware: [Middleware<State>] = []) {
        var currentState = reducer(state, "@@INIT")
        let subject = PublishSubject<Action>()
        let queue = DispatchQueue(label: "\(Store.self).getState", attributes: .concurrent)
        
        let _getState: GetState<State> = {
            var state: State!
            queue.sync {
                state = currentState
            }
            return state
        }
        getState = _getState
        
        observable = subject
            .scan(currentState) {
                let newState = reducer($0, $1)
                queue.async(flags: .barrier) {
                    currentState = newState
                }
                return newState
            }
            .startWith(currentState)
            .share(replay: 1)
        
        dispatch = {
            // TODO: handle dispatch from multiple queues? Maybe pool strategy?
            subject
                .onNext($0)
        }
        
        if !middleware.isEmpty {
            let _dispatch: Dispatch = { [weak self] in
                self?.dispatch($0)
            }
            
            dispatch = middleware
                .reversed()
                .reduce(dispatch) { next, middleware in
                    middleware(_dispatch, _getState)(next)
            }
        }
        
        // TODO: can we switch to hot observable?
        observable
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}

extension Store {
    
    public typealias Unsubscribe = () -> Void
    
    public func subscribe(subscription: @escaping (State) -> Void) -> Unsubscribe {
        let subscription = observable
            // TODO: add ability to subscribe on a queue?
            .subscribe(onNext: subscription)
        
        return {
            subscription.dispose()
        }
    }
    
}
