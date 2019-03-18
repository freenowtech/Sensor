//
//  DemoTableViewModel.swift
//  LoginDemoRxRedux
//
//  Created by Ferran Pujol Camins on 06/11/2018.
//  Copyright © 2018 Mounir Dellagi. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxCocoa

struct DemoTableStore {
    let inputEvents: Signal<Event>

    init(refreshButton: Signal<Void>) {
        self.inputEvents = refreshButton.map{ .refreshTapped }
    }

    var output: Driver<DemoTableView.Model> {
        let initialState = State.presentingData([])
        let context = Context(getAllCharacters: UseCase.defaultGetAllCharacters)
        
        return State.outputStates(initialState: initialState,
                                  inputEvents: inputEvents.startWith(.refreshTapped),
                                  context: context)
            .map { state in DemoTableView.Model(state) }
            .distinctUntilChanged()
    }
    
    enum Event: Equatable {
        case requestSucceded([DemoCellModel])
        case requestFailed(APIError)
        case refreshTapped
    }
    
    struct Context {
        let getAllCharacters: UseCase.GetAllCharacters
    }

    enum Effect: TriggerableEffect {
        case getAllCharacters
        
        func trigger(context: Context) -> Signal<Event> {
            switch self {
            case .getAllCharacters:
                return context
                    .getAllCharacters()
                    .map { response -> Event in .requestSucceded(response.map{ DemoCellModel($0) }) }
                    .asSignal { error in
                        return Signal.just(Event.requestFailed((error as? APIError)!))
                    }
            }
        }
    }
    
    enum State: ReducibleStateWithEffects {
        case fetchingData
        case presentingData([DemoCellModel])
        case presentingError(APIError)
        
        func reduce(event: Event) -> (state: State, effects: Set<Effect>) {
            switch (self, event) {
            case (.fetchingData, .requestFailed(let error)):
                return (.presentingError(error), [])
                
            case (.fetchingData, .requestSucceded(let characters)):
                return (.presentingData(characters), [])

            case (.presentingData(_), .refreshTapped):
                return (.fetchingData, [.getAllCharacters])

            case (.presentingError, .refreshTapped):
                return (.fetchingData, [.getAllCharacters])

            default:
                return (self, [])
            }
        }
    }
}
