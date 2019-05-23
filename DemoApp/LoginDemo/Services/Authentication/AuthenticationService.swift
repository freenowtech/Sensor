//
//  Authentication.swift
//  LoginDemo
//
//  Created by Adrian Zdanowicz on 08/05/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation

protocol AuthenticationServiceProtocol {
    var authenticated: Bool { get }
}

struct AuthenticationService: AuthenticationServiceProtocol {
    var authenticated: Bool {
        return false
    }
}
