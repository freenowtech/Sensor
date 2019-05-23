//
//  DemoTableViewModel.swift
//  LoginDemo
//
//  Created by Ferran Pujol Camins on 06/11/2018.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import Sensor
import RxCocoa

struct DemoTableStore {
    let inputEvents: Signal<Event>

    init(refreshButton: Signal<Void>) {
        self.inputEvents = refreshButton.map{ .refreshTapped }
    }

    var output: Driver<DemoTableView.Model> {
        let initialState = State.presentingData([])
        let context = Context(getAllPois: UseCase.defaultGetAllPois)
        
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
        let getAllPois: UseCase.GetAllPois
    }

    enum Effect: TriggerableEffect {
        case getAllPois
        
        func trigger(context: Context) -> Signal<Event> {
            switch self {
            case .getAllPois:
                return context
                    .getAllPois()
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
                
            case (.fetchingData, .requestSucceded(let pois)):
                return (.presentingData(pois), [])

            case (.presentingData(_), .refreshTapped):
                return (.fetchingData, [.getAllPois])

            case (.presentingError, .refreshTapped):
                return (.fetchingData, [.getAllPois])

            default:
                return (self, [])
            }
        }
    }
}
