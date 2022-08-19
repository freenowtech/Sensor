//
//  LoginStore+reducer.swift
//  LoginDemo
//
//  Created by Marcin Religa on 29/6/22.
//  Copyright © 2022 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import Sensor

extension LoginStore {
    public static let reducer = Reducer<State, Effect, Event> { state, event in
        switch (state.state, event) {
        case (.loggedOut, .passwordToggled):
            return then().goTo(State(credentials: state.credentials, isPasswordHidden: !state.isPasswordHidden, state: .loggedOut))

        case (.loggedOut, .usernameChanged(let username)):
            let newCredentials = Credentials(username: username, password: state.credentials.password)
            return then()
                .goTo(State(credentials: newCredentials, isPasswordHidden: state.isPasswordHidden, state: .loggedOut))

        case (.loggedOut, .passwordChanged(let password)):
            let newCredentials = Credentials(username: state.credentials.username, password: password)
            return then()
                .goTo(State(credentials: newCredentials, isPasswordHidden: state.isPasswordHidden, state: .loggedOut))

        case (.loggedOut, .loginButtonTapped):
            return then()
                .trigger(.loginRequest(username: state.credentials.username, password: state.credentials.password))
                .goTo(State(credentials: state.credentials, isPasswordHidden: state.isPasswordHidden, state: .performingLogin))

        case (.performingLogin, .loginRequestSucceeded(let user)):
            return then().goTo(State(credentials: state.credentials, isPasswordHidden: state.isPasswordHidden, state: .loggedIn(user)))

        case (.performingLogin, .loginRequestFailed(let error)):
            return then()
                .goTo(State(credentials: state.credentials, isPasswordHidden: state.isPasswordHidden, state: .loginFailed(error)))

        case (.loginFailed, .errorMessageDismissed):
            return then().goTo(State(credentials: state.credentials, isPasswordHidden: state.isPasswordHidden, state: .loggedOut))
        default:
            return then()
                .trigger([])
                .stayOnCurrentState()
        }
    }
}
