//
//  DetailStore+reducer.swift
//  LoginDemo
//
//  Created by Marcin Religa on 29/6/22.
//  Copyright © 2022 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import Sensor

// TODO: MR: Move to another file.
extension DetailStore {
    public static let reducer = Reducer<State, Effect, Event> { state, event in
        switch (state, event) {
        case (.presenting(let color), .changeColorPressed):
            return then().trigger(.getRandomColor).goTo(.presenting(color))
        case (.presenting, .colorFetched(let color)):
            return then().goTo(.presenting(color))
        case (.presenting, .backPressed):
            return then().goTo(.exiting)
        default:
            return then()
                .trigger([])
                .stayOnCurrentState()
        }
    }
}
