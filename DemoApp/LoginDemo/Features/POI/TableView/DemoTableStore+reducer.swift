//
//  DemoTableStore+reducer.swift
//  LoginDemo
//
//  Created by Marcin Religa on 29/6/22.
//  Copyright © 2022 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import Sensor

extension DemoTableStore {
    public static let reducer = Reducer<State, Effect, Event> { state, event in
        switch (state, event) {
        case (.fetchingData, .requestFailed(let error)):
            return then()
                .goTo(.presentingError(error))
        case (.fetchingData, .requestSucceded(let pois)):
            return then()
                .goTo(.presentingData(pois))
        case (.presentingData, .refreshTapped):
            return then()
                .trigger(.getAllPois)
                .goTo(.fetchingData)
        case (.presentingError, .refreshTapped):
            return then()
                .trigger(.getAllPois)
                .goTo(.fetchingData)
        case (.presentingData(let pois), .cellSelected(let index)):
            return then()
                .trigger(.cellSelected(pois[index]))
                .goTo(state)
        default:
            return then()
                .trigger([])
                .stayOnCurrentState()
        }
    }
}
