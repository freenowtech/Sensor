//
//  DetailStore.swift
//  LoginDemo
//
//  Created by Adrian Zdanowicz on 07/05/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import UIKit.UIColor
import RxFeedback
import RxSwift
import RxCocoa
import Sensor

struct DetailStore {
    
    struct Outputs<ViewModel, Navigation> {
        let viewDriver: Driver<ViewModel>
        let navigationDriver: Signal<Navigation>
    }
    
    enum Event: Equatable {
        case changeColorPressed
        case backPressed
        case colorFetched(UIColor)
    }
    
    struct Context {
        let getRandomColor: UseCase.GetRandomColor
    }
    
    static func makeOutputs(inputs: DetailView.Outputs) -> Outputs<DetailView.Model, Navigation> {
        let inputEvents: Signal<Event> = Signal.merge(inputs.buttonTapped.map { _ in .changeColorPressed},
                                                      inputs.backTapped.map { _ in .backPressed })
        
        let initialState = State.presenting(.white)
        let context = Context(getRandomColor: UseCase.getRandomColor())
        
        let viewOutput = State.outputStates(initialState: initialState,
                                                 inputEvents: inputEvents,
                                                 context: context)
            .map { state in DetailView.Model(state) }
            .distinctUntilChanged()
        
        let navigationOutput = viewOutput.flatMap { model -> Signal<Navigation> in
            switch model {
            case .exiting:
                return Signal.just(.pop)
            default:
                return Signal.empty()
            }
        }
        return Outputs(viewDriver: viewOutput, navigationDriver: navigationOutput)
    }
    
    // MARK: Private
    
    enum Effect {
        case getRandomColor
    }
    
    private let internalState: Driver<State>
    
    enum State {
        case presenting(UIColor)
        case exiting
    }
}

extension DetailStore.State: ReducibleStateWithEffects {
    typealias Event = DetailStore.Event
    typealias State = DetailStore.State
    typealias Effect = DetailStore.Effect
    
    func reduce(event: Event) -> (state: State, effects: Set<Effect>) {
        switch (self, event) {
        case (.presenting(let color), .changeColorPressed):
            return (.presenting(color), [.getRandomColor])
        case (.presenting, .colorFetched(let color)):
            return (.presenting(color), [])
        case (.presenting, .backPressed):
            return (.exiting, [])
        default:
            return (self, [])
        }
    }
}

extension DetailStore.Effect: TriggerableEffect {
    typealias Context = DetailStore.Context
    typealias Event = DetailStore.Event
    
    func trigger(context: Context) -> Signal<Event> {
        switch self {
        case .getRandomColor:
            return context
                .getRandomColor()
                .map { color -> Event in .colorFetched(color) }
                .asSignal(onErrorJustReturn: .colorFetched(.red))
        }
    }
}

extension DetailView.Model {
    init(_ state: DetailStore.State) {
        switch state {
        case .presenting(let color):
            self = .presentingData(color)
        case .exiting:
            self = .exiting
        }
    }
}

