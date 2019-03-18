//
//  LoginAPI.swift
//  LoginDemoRxRedux
//
//  Created by Mounir Dellagi on 25.02.18.
//  Copyright © 2018 Mounir Dellagi. All rights reserved.
//

import Foundation
import RxSwift

struct LoginRequestModel: Hashable {
    let username: String
    let password: String
}

struct User: Hashable {
    let username: String
    let age: Int
}

enum APIError: String, Hashable, Error {
    case wrongCredentials
    case serverError
    var localizedDescription: String { return self.rawValue }
}

enum APIResult<T> {
    case success(T)
    case error(APIError)
}

protocol LoginAPIProtocol {
    func loginUser(loginPayload: LoginRequestModel) -> Single<User>
}

final class LoginAPIMock: LoginAPIProtocol {
    let result: APIResult<User>

    init(result: APIResult<User>) {
        self.result = result
    }

    func loginUser(loginPayload: LoginRequestModel) -> Single<User> {
        switch result {
        case .success(let user):
            return Single.just(user)
        case .error(let error):
            return Single.error(error)
        }
    }
}

final class LoginAPI: LoginAPIProtocol {
    func loginUser(payload: LoginRequestModel, completion: (APIResult<User>) -> Void) {
        if Int(arc4random()) % 2 == 1 {
            let user = User(username: "Test User", age: 1)
            let result = APIResult.success(user)
            completion(result)
        } else {
            let error: APIError = .wrongCredentials
            let result: APIResult<User> = .error(error)
            completion(result)
        }
    }

    func loginUser(loginPayload: LoginRequestModel) -> Single<User> {
        return Single
            .create { [weak self] observer in
                self?.loginUser(payload: loginPayload) { result in
                    switch result {
                    case .success(let user):
                         return observer(.success(user))
                    case .error(let error):
                         return observer(.error(error))
                    }
                }
                return Disposables.create()
            }
    }
}
