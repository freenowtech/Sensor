//
//  DemoTableViewModel.swift
//  LoginDemo
//
//  Created by Ferran Pujol Camins on 06/11/2018.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxCocoa
import Sensor

struct DemoTableStore {
    typealias Input = (refreshTapped: Signal<Void>, cellSelected: Signal<Int>)
    typealias ViewOutput = Driver<DemoTableView.Model>
    typealias CoordinatorOutput = Signal<Navigation>
    typealias Output = (forView: ViewOutput, forCoordinator: CoordinatorOutput)

    enum Event: Equatable {
        case cellSelected(Int)
        case requestSucceded([POI])
        case requestFailed(APIError)
        case refreshTapped
    }

    struct Context {
        let getAllPois: UseCase.GetAllPois
        let selectedCellRelay = PublishRelay<POI>()
    }

    static func makeOutputs(inputs: Input) -> Output {
        let inputEvents = Signal<Event>.merge(
            inputs.refreshTapped.map { .refreshTapped }.startWith(.refreshTapped),
            inputs.cellSelected.map { .cellSelected($0) }
        )
        let context = Context(getAllPois: UseCase.defaultGetAllPois)

        let initialState = State.presentingData([])
        let state = State.outputStates(initialState: initialState,
                                       inputEvents: inputEvents,
                                       context: context)


        let outputForView = state
            .map { DemoTableView.Model($0) }
            .distinctUntilChanged()

        return (forView: outputForView, forCoordinator: context.selectedCellRelay.asSignal(onErrorSignalWith: Signal.never()).map { poi in Navigation.detail(poi) })
    }

    // MARK: Private

    enum Effect {
        case getAllPois
        case cellSelected(POI)
    }

    private let internalState: Driver<State>
    
    enum State {
        case fetchingData
        case presentingData([POI])
        case presentingError(APIError)
    }
}

extension DemoTableStore.State: ReducibleStateWithEffects {
    typealias Event = DemoTableStore.Effect.Event
    typealias State = DemoTableStore.State
    typealias Effect = DemoTableStore.Effect

    func reduce(event: Event) -> (state: State, effects: Set<Effect>) {
        switch (self, event) {
        case (.fetchingData, .requestFailed(let error)):
            return (.presentingError(error), [])

        case (.fetchingData, .requestSucceded(let pois)):
            return (.presentingData(pois), [])

        case (.presentingData, .refreshTapped):
            return (.fetchingData, [.getAllPois])

        case (.presentingError, .refreshTapped):
            return (.fetchingData, [.getAllPois])

        case (.presentingData(let pois), .cellSelected(let index)):
            return (self, [.cellSelected(pois[index])])

        default:
            return (self, [])
        }
    }
}

extension DemoTableStore.Effect: TriggerableEffect {
    typealias Context = DemoTableStore.Context
    typealias Event = DemoTableStore.Event

    func trigger(context: Context) -> Signal<Event> {
        switch self {
        case .getAllPois:
            return context
                .getAllPois()
                .map { response -> Event in .requestSucceded(response) }
                .asSignal { error in
                    return Signal.just(Event.requestFailed((error as? APIError)!))
            }
        // TODO: this should be an action
        case .cellSelected(let poi):
            context.selectedCellRelay.accept(poi)
            return Signal.never()
        }
    }
}

extension DemoTableView.Model {
    fileprivate init(_ state: DemoTableStore.State) {
        switch state {
        case .fetchingData:
            self = .fetchingData

        case .presentingData(let newPois):
            self = .presentingData(newPois.map { DemoCellModel($0) })

        case .presentingError(_):
            self = .presentingError
        }
    }
}
