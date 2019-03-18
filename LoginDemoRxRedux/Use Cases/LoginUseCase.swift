//
//  LoginUseCase.swift
//  LoginDemoRxRedux
//
//  Created by Lluís Gómez on 11/03/2019.
//  Copyright © 2019 Mounir Dellagi. All rights reserved.
//

import Foundation
import RxSwift

extension UseCase {

    typealias Login = (_ username: String, _ password: String) -> Single<User>

    static var defaultLogin: Login {
        let api: LoginAPIProtocol = DependencyRetriever.loginApi()

        return { username, password in
            let requestModel = LoginRequestModel(username: username, password: password)
            return api.loginUser(loginPayload: requestModel)
        }
    }
}
