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

struct DemoTableStore: SensorFeature {
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

    public let effectsImplementation: EffectsImplementation<Effect, Event>

    init(context: Context) {
        self.effectsImplementation = Self.effectsImplementation(context: context)
    }

    static private func effectsImplementation(context: Context) -> EffectsImplementation<Effect, Event> {
        EffectsImplementation { effect in
            switch effect {
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

            }
            return .empty()
        }
    }

    func makeOutputs(inputs: Input) -> Output {
        let inputEvents = Signal<Event>.merge(
            inputs.refreshTapped.map { .refreshTapped }.startWith(.refreshTapped),
            inputs.cellSelected.map { .cellSelected($0) }
        )
        let context = Context(getAllPois: UseCase.defaultGetAllPois)

        let state = outputStates(initialState: State.presentingData([]),
                                 inputEvents: inputEvents)

        let outputForView = state
            .map { DemoTableView.Model($0) }
            .distinctUntilChanged()

        return (forView: outputForView, forCoordinator: context.selectedCellRelay.asSignal(onErrorSignalWith: Signal.never()).map { poi in Navigation.detail(poi) })
    }

    // MARK: Private

    enum Effect: Hashable {
        case getAllPois
        case cellSelected(POI)
    }
    
    enum State: Equatable {
        case fetchingData
        case presentingData([POI])
        case presentingError(APIError)
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
