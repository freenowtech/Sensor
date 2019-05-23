//
//  DependencyRetriever.swift
//  LoginDemo
//
//  Created by Mounir Dellagi on 24.10.18.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import Swinject

final class DependencyRetriever: NSObject {
    static var container = Container()

    static func setupDependencies() {
        container
            .register(LoginAPIProtocol.self) { _ in LoginAPI() }
            .inObjectScope(.container)
        
        container
            .register(POIServiceProtocol.self) { _ in POIService() }
            .inObjectScope(.container)
        
        container
            .register(AuthenticationServiceProtocol.self) { _ in AuthenticationService() }
            .inObjectScope(.container)
    }

    static func loginApi() -> LoginAPIProtocol {
        return container.resolve(LoginAPIProtocol.self)!
    }
    
    static func poiServiceAPI() -> POIServiceProtocol {
        return container.resolve(POIServiceProtocol.self)!
    }
    
    static func authenticationService() -> AuthenticationServiceProtocol {
        return container.resolve(AuthenticationServiceProtocol.self)!
    }
}
