//
//  LoginDemoTests.swift
//  LoginDemoTests
//
//  Created by Mounir Dellagi on 13.02.18.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import XCTest
import Nimble
import Nimble_Snapshots
import RxTest
import RxSwift
import RxCocoa
import UIKit
import Swinject

@testable import LoginDemo

class LoginDemoTests: XCTestCase {
    
    private let loginView = LoginView()
    let initialModel = LoginView.Model(isLoginButtonEnabled: false, isPasswordHidden: true, isSpinning: false, state: .loggedOut)
    
    override func setUp() {
        super.setUp()
        DependencyRetriever.setupDependencies()
        loginView.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(UIScreen.main.bounds.height)
        }
    }
    
    override func tearDown() {
        DependencyRetriever.container = Container()
        super.tearDown()
    }

    func testEmptyPassword() {
        typealias RecEvent = Event<LoginView.Model>

        let scheduler = TestScheduler(initialClock: 0)

        let usernameEvent = scheduler.parseEventsAndTimes(timeline: "-a", values: [ /* Input Events */
            "a": "abcdefgh"
            ])

        let passwordEvents = scheduler.parseEventsAndTimes(timeline: "-a", values: [ /* Input Events */
            "a": ""
            ])

        let usernameSignal: Signal<String> = scheduler.createHotObservable(usernameEvent).asSignal(onErrorJustReturn: "")
        let passwordSignal: Signal<String> = scheduler.createHotObservable(passwordEvents).asSignal(onErrorJustReturn: "")

        let recorded = scheduler.record(source: LoginStore.makeOutputs(inputs: LoginView.Outputs(usernameField: usernameSignal,
                                                                                            passwordField: passwordSignal,
                                                                                            loginButton: .empty(),
                                                                                            registerButton: .empty(),
                                                                                            showPasswordButton: .empty()),
                                                                  alertInput: .empty()))



        let expectedEventModels = ["a": initialModel]
        let expectedEvents = scheduler.parseEventsAndTimes(timeline: "a", values: expectedEventModels)

        scheduler.start()

        XCTAssertEqual(recorded.events, expectedEvents)
    }

    func testCorrectPassword() {
        typealias RecEvent = Event<LoginView.Model>

        let scheduler = TestScheduler(initialClock: 0)

        let usernameEvent = scheduler.parseEventsAndTimes(timeline: "-a", values: [ /* Input Events */
            "a": "abcdefgh"
            ])

        let passwordEvents = scheduler.parseEventsAndTimes(timeline: "--a", values: [ /* Input Events */
            "a": "12345678"
            ])

        let usernameSignal: Signal<String> = scheduler.createHotObservable(usernameEvent).asSignal(onErrorJustReturn: "")
        let passwordSignal: Signal<String> = scheduler.createHotObservable(passwordEvents).asSignal(onErrorJustReturn: "")

        let recorded = scheduler.record(source: LoginStore.makeOutputs(inputs: LoginView.Outputs(usernameField: usernameSignal,
                                                                                                           passwordField: passwordSignal,
                                                                                                           loginButton: .empty(),
                                                                                                           registerButton: .empty(),
                                                                                                           showPasswordButton: .empty()),
                                                                  alertInput: .empty()))

        let correctUsernameAndPWModel = LoginView.Model(isLoginButtonEnabled: true, isPasswordHidden: true, isSpinning: false, state: .loggedOut)

        let expectedEventModels = ["a": initialModel, "b": correctUsernameAndPWModel]
        let expectedEvents = scheduler.parseEventsAndTimes(timeline: "a-b", values: expectedEventModels)

        scheduler.start()

        XCTAssertEqual(recorded.events, expectedEvents)
    }

    func testIncorrectPassword() {
        typealias RecEvent = Event<LoginView.Model>

        let scheduler = TestScheduler(initialClock: 0)

        let usernameEvent = scheduler.parseEventsAndTimes(timeline: "-a", values: [ /* Input Events */
            "a": "abcdefgh"
            ])

        let passwordEvents = scheduler.parseEventsAndTimes(timeline: "--a", values: [ /* Input Events */
            "a": "%%%%%%%%%%"
            ])

        let usernameSignal: Signal<String> = scheduler.createHotObservable(usernameEvent).asSignal(onErrorJustReturn: "")
        let passwordSignal: Signal<String> = scheduler.createHotObservable(passwordEvents).asSignal(onErrorJustReturn: "")

        let recorded = scheduler.record(source: LoginStore.makeOutputs(inputs: LoginView.Outputs(usernameField: usernameSignal,
                                                                                            passwordField: passwordSignal,
                                                                                            loginButton: .empty(),
                                                                                            registerButton: .empty(),
                                                                                            showPasswordButton: .empty()),
                                                                  alertInput: .empty()))

        let expectedEventModels = ["a": initialModel]
        let expectedEvents = scheduler.parseEventsAndTimes(timeline: "a", values: expectedEventModels)

        scheduler.start()

        XCTAssertEqual(recorded.events, expectedEvents)
    }

    func testCorrectLogin() {
        let container = Container()
        let apiMock = LoginAPIMock(result: APIResult.success(User(username: "Hans", age: 1)))

        container
            .register(LoginAPIProtocol.self) { _ in apiMock }
            .inObjectScope(.container)

        DependencyRetriever.container = container

        typealias RecEvent = Event<LoginView.Model>

        let scheduler = TestScheduler(initialClock: 0, resolution: 1, simulateProcessingDelay: false)

        SharingScheduler.mock(scheduler: scheduler) {
            let usernameEvent = scheduler.parseEventsAndTimes(timeline: "-a", values: [ /* Input Events */
                "a": "abcdefgh"
                ])

            let passwordEvents = scheduler.parseEventsAndTimes(timeline: "--a", values: [ /* Input Events */
                "a": "12345678"
                ])

            let buttonEvent = scheduler.parseEventsAndTimes(timeline: "---a", values: [ /* Input Events */
                "a": ()
                ])

            let buttonClickSignal: Signal<Void> = scheduler.createHotObservable(buttonEvent).asSignal(onErrorJustReturn: ())
            let usernameSignal: Signal<String> = scheduler.createHotObservable(usernameEvent).asSignal(onErrorJustReturn: "")
            let passwordSignal: Signal<String> = scheduler.createHotObservable(passwordEvents).asSignal(onErrorJustReturn: "")

            let correctUsernameAndPWModel = LoginView.Model(isLoginButtonEnabled: true, isPasswordHidden: true, isSpinning: false, state: .loggedOut)

            let performingLoginModel = LoginView.Model(isLoginButtonEnabled: false, isPasswordHidden: true, isSpinning: true, state: .performingLogin)

            let loggedInModel = LoginView.Model(isLoginButtonEnabled: true, isPasswordHidden: true, isSpinning: false, state: .loggedIn(User(username: "Hans", age: 1)))

            let recorded = scheduler.record(source: LoginStore.makeOutputs(inputs: LoginView.Outputs(usernameField: usernameSignal,
                                                                                         passwordField: passwordSignal,
                                                                                         loginButton: buttonClickSignal,
                                                                                         registerButton: .empty(),
                                                                                         showPasswordButton: .empty()),
                                                                      alertInput: .empty()))

            let expectedEventModels = ["a": initialModel, "c": correctUsernameAndPWModel, "d": performingLoginModel, "e": loggedInModel]
            let expectedEvents = scheduler.parseEventsAndTimes(timeline: "a-cde", values: expectedEventModels)

            scheduler.start()

            XCTAssertEqual(recorded.events, expectedEvents)
        }

    }

    func testTogglePassword() {
        let container = Container()
        let apiMock = LoginAPIMock(result: APIResult.success(User(username: "Hans", age: 1)))

        container
            .register(LoginAPIProtocol.self) { _ in apiMock }
            .inObjectScope(.container)

        DependencyRetriever.container = container

        typealias RecEvent = Event<LoginView.Model>

        let scheduler = TestScheduler(initialClock: 0, resolution: 1, simulateProcessingDelay: false)

        SharingScheduler.mock(scheduler: scheduler) {
            let usernameEvent = scheduler.parseEventsAndTimes(timeline: "-a", values: [ /* Input Events */
                "a": "abcdefgh"
                ])

            let passwordEvents = scheduler.parseEventsAndTimes(timeline: "--a", values: [ /* Input Events */
                "a": "12345678"
                ])

            let toggleEvent = scheduler.parseEventsAndTimes(timeline: "---ab", values: [ /* Input Events */
                "a": (),
                "b": ()
                ])

            let toggleSignal: Signal<Void> = scheduler.createHotObservable(toggleEvent).asSignal(onErrorJustReturn: ())
            let usernameSignal: Signal<String> = scheduler.createHotObservable(usernameEvent).asSignal(onErrorJustReturn: "")
            let passwordSignal: Signal<String> = scheduler.createHotObservable(passwordEvents).asSignal(onErrorJustReturn: "")

            let recorded = scheduler.record(source: LoginStore.makeOutputs(inputs: LoginView.Outputs(usernameField: usernameSignal,
                                                                                         passwordField: passwordSignal,
                                                                                         loginButton: .empty(),
                                                                                         registerButton: .empty(),
                                                                                         showPasswordButton: toggleSignal),
                                                                      alertInput:.empty()))

            let correctUsernameAndPWModelPasswordHidden = LoginView.Model(isLoginButtonEnabled: true, isPasswordHidden: true, isSpinning: false, state: .loggedOut)

            let correctUsernameAndPWModelPasswordVisible = LoginView.Model(isLoginButtonEnabled: true, isPasswordHidden: false, isSpinning: false, state: .loggedOut)

            let expectedEventModels = ["a": initialModel, "c": correctUsernameAndPWModelPasswordHidden, "d": correctUsernameAndPWModelPasswordVisible, "e": correctUsernameAndPWModelPasswordHidden]
            let expectedEvents = scheduler.parseEventsAndTimes(timeline: "a-cde", values: expectedEventModels)

            scheduler.start()

            XCTAssertEqual(recorded.events, expectedEvents)
        }

    }

    func testIncorrectLogin() {
        let container = Container()
        let apiMock = LoginAPIMock(result: APIResult.error(APIError.wrongCredentials))

        container
            .register(LoginAPIProtocol.self) { _ in apiMock }
            .inObjectScope(.container)

        DependencyRetriever.container = container

        typealias RecEvent = Event<LoginView.Model>

        let scheduler = TestScheduler(initialClock: 0, resolution: 1, simulateProcessingDelay: false)

        SharingScheduler.mock(scheduler: scheduler) {
            let usernameEvent = scheduler.parseEventsAndTimes(timeline: "-a", values: [ /* Input Events */
                "a": "abcdefgh"
                ])

            let passwordEvents = scheduler.parseEventsAndTimes(timeline: "--a", values: [ /* Input Events */
                "a": "12345678"
                ])

            let buttonEvent = scheduler.parseEventsAndTimes(timeline: "---a", values: [ /* Input Events */
                "a": ()
                ])

            let buttonClickSignal: Signal<Void> = scheduler.createHotObservable(buttonEvent).asSignal(onErrorJustReturn: ())
            let usernameSignal: Signal<String> = scheduler.createHotObservable(usernameEvent).asSignal(onErrorJustReturn: "")
            let passwordSignal: Signal<String> = scheduler.createHotObservable(passwordEvents).asSignal(onErrorJustReturn: "")

            let recorded = scheduler.record(source: LoginStore.makeOutputs(inputs: LoginView.Outputs(usernameField: usernameSignal,
                                                                                         passwordField: passwordSignal,
                                                                                         loginButton: buttonClickSignal,
                                                                                         registerButton: .empty(),
                                                                                         showPasswordButton: .empty()), alertInput:.empty()))

            let correctUsernameAndPWModel = LoginView.Model(isLoginButtonEnabled: true, isPasswordHidden: true, isSpinning: false, state: .loggedOut)

            let performingLoginModel = LoginView.Model(isLoginButtonEnabled: false, isPasswordHidden: true, isSpinning: true, state: .performingLogin)

            let failureModel = LoginView.Model(isLoginButtonEnabled: true, isPasswordHidden: true, isSpinning: false, state: .loginFailed(APIError.wrongCredentials))

            let expectedEventModels = ["a": initialModel, "c": correctUsernameAndPWModel, "d": performingLoginModel, "e": failureModel]
            let expectedEvents = scheduler.parseEventsAndTimes(timeline: "a-cde", values: expectedEventModels)

            scheduler.start()

            XCTAssertEqual(recorded.events, expectedEvents)
        }
    }

    // MARK: - Snapshot Tests

    // When true, all the tests record a snapshot and fail.
    // When false, all tests assert the view agains the recorded snapshot
    static let recordSnapshots = false

    func recordOrAssertSnapshot(on view: UIView) {
        if LoginDemoTests.recordSnapshots {
            expect(view).to(recordDeviceAgnosticSnapshot())
        } else {
            expect(view).to(haveValidDeviceAgnosticSnapshot())
        }
    }

    func testSnapshot_LoggedOut_PasswordNotHidden_LoginButtonEnabled() {
        let loginViewModel = LoginView.Model(isLoginButtonEnabled: true, isPasswordHidden: false, isSpinning: false, state: .loggedOut)
        let inputs: Binder<LoginView.Model> = loginView.rx.inputs
        _ = Driver.just(loginViewModel).drive(inputs)

        recordOrAssertSnapshot(on: loginView)
    }

    func testSnapshot_LoggedOut_PasswordHidden_LoginButtonDisabled() {
        let loginViewModel = LoginView.Model(isLoginButtonEnabled: false, isPasswordHidden: true, isSpinning: false, state: .loggedOut)
        let inputs: Binder<LoginView.Model> = loginView.rx.inputs
        _ = Driver.just(loginViewModel).drive(inputs)

        recordOrAssertSnapshot(on: loginView)
    }

    func testSnapshot_PerformingLogin_LoginButtonDisabled() {
        let loginViewModel = LoginView.Model(isLoginButtonEnabled: false, isPasswordHidden: true, isSpinning: true, state: .performingLogin)
        let inputs: Binder<LoginView.Model> = loginView.rx.inputs
        _ = Driver.just(loginViewModel).drive(inputs)

        recordOrAssertSnapshot(on: loginView)
    }

    func testSnapshot_LoginFailed_LoginButtonDisabled() {
        let apiError = APIError.wrongCredentials
        let loginViewModel = LoginView.Model(isLoginButtonEnabled: false, isPasswordHidden: true, isSpinning: false, state: .loginFailed(apiError))
        let inputs: Binder<LoginView.Model> = loginView.rx.inputs
        _ = Driver.just(loginViewModel).drive(inputs)

        recordOrAssertSnapshot(on: loginView)
    }

    func testSnapshot_LoginFailed_LoginButtonEnabled() {
        let apiError = APIError.wrongCredentials
        let loginViewModel = LoginView.Model(isLoginButtonEnabled: true, isPasswordHidden: true, isSpinning: false, state: .loginFailed(apiError))
        let inputs: Binder<LoginView.Model> = loginView.rx.inputs
        _ = Driver.just(loginViewModel).drive(inputs)

        recordOrAssertSnapshot(on: loginView)
    }
}
