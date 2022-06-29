//
//  FeedbackViewModel.swift
//  LoginDemo
//
//  Created by Mounir Dellagi on 26.06.18.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import Sensor
import RxFeedback
import RxSwift
import RxCocoa

struct LoginStore: SensorFeature {
    struct Outputs<ViewModel, Navigation> {
        let viewDriver: Driver<ViewModel>
        let navigationDriver: Signal<Navigation>
    }

    public let effectsImplementation: EffectsImplementation<Effect, Event>

    init(context: Context) {
        self.effectsImplementation = Self.effectsImplementation(context: context)
    }

    func makeOutputs(inputs: LoginView.Outputs, alertInput: Signal<RxAlertResult>) -> Outputs<LoginView.Model, Navigation> {
        let inputEvents: Signal<Event> = Signal.merge(
            inputs.usernameField.map { .usernameChanged($0) },
            inputs.passwordField.map { .passwordChanged($0) },
            inputs.loginButton.map { .loginButtonTapped },
            inputs.showPasswordButton.map { .passwordToggled },
            alertInput.map { _ in .errorMessageDismissed }
        )

        let initalStateModel = State(credentials: Credentials(username: "", password: ""), isPasswordHidden: true, state: .loggedOut)

        let viewOutput = outputStates(initialState: initalStateModel,
                                 inputEvents: inputEvents)
            .map { stateModel in LoginView.Model(stateModel: stateModel) }
            .distinctUntilChanged()

        let navigationOutput = viewOutput.flatMap { model -> Signal<Navigation> in
            switch model.state {
            case .loggedIn:
                return Signal.just(.dismiss)
            case .loginFailed:
                return Signal.just(.showError)
            default:
                return Signal.empty()
            }
        }
        return Outputs(viewDriver: viewOutput, navigationDriver: navigationOutput)
    }

    struct Context { // Will be done by David or/and Stefan in Interactor/Use Case Refactor
        let login: UseCase.Login
    }

    /// The actions that can be performed on the view model
    enum Event: Equatable {
        case usernameChanged(String)
        case passwordChanged(String)
        case loginButtonTapped
        case passwordToggled
        case errorMessageDismissed

        case loginRequestSucceeded(User) // Asynchronous Feedback Event
        case loginRequestFailed(APIError) // Asynchronous Feedback Event
    }

    static private func effectsImplementation(context: Context) -> EffectsImplementation<Effect, Event> {
        EffectsImplementation { effect in
            switch effect {
            case .loginRequest(let username, let password):
                return context
                    .login(username, password)
                    .map { response -> Event in .loginRequestSucceeded(response) }
                    .asSignal { error in
                        return Signal.just(Event.loginRequestFailed((error as? APIError)!))
                    }
                // TODO: MR: Fix this.
                    .delay(1)
            return .empty()
            }
        }
    }

    enum Effect: Hashable {
        case loginRequest(username: String, password: String)
    }

    struct Credentials: Hashable {
        let username: String
        let password: String
    }

    enum StateInternal: Hashable {
        case loggedOut, loggedIn(User), loginFailed(APIError), performingLogin
    }

    struct State {
        let credentials: Credentials
        let isPasswordHidden: Bool
        let state: StateInternal
    }
}

private extension LoginStore.Credentials {
    private func checkPasswordValidity(_ password: String) -> Bool {
        return password.count > 7 && password.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil
    }

    var valid: Bool {
        return username.count > 5 && checkPasswordValidity(password)
    }
}

private extension LoginView.Model {
    init(stateModel: LoginStore.State) {
        self.isSpinning = stateModel.state == .performingLogin
        self.isLoginButtonEnabled = stateModel.credentials.valid && stateModel.state != .performingLogin
        self.isPasswordHidden = stateModel.isPasswordHidden
        self.state = stateModel.state
    }
}
