//
//  DependencyRetriever.swift
//  LoginDemoRxRedux
//
//  Created by Mounir Dellagi on 24.10.18.
//  Copyright © 2018 Mounir Dellagi. All rights reserved.
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
            .register(GOTServiceProtocol.self) { _ in GOTService() }
            .inObjectScope(.container)
    }

    static func loginApi() -> LoginAPIProtocol {
        return container.resolve(LoginAPIProtocol.self)!
    }
    
    static func gotServiceAPI() -> GOTServiceProtocol {
        return container.resolve(GOTServiceProtocol.self)!
    }
}
