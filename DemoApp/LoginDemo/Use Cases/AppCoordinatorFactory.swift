//
//  AppCoordinatorFactory.swift
//  LoginDemo
//
//  Created by Adrian Zdanowicz on 08/05/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import UIKit.UIViewController
import RxSwift
import RxCocoa

extension UseCase {
    
    static func createAppCoordinatorPayload(window: UIWindow) -> (rootViewController: UIViewController, coordinatorPayload: CoordinatorPayload) {
        let viewController = DemoTableViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        let authService = DependencyRetriever.authenticationService()
        let navigationOutput = authService.authenticated ? viewController.coordinatorOutputs : viewController.coordinatorOutputs.startWith(.login)
        return (rootViewController: viewController, coordinatorPayload: CoordinatorPayload(viewController: navigationController,
            navigationOutput: navigationOutput,
            path: .tableView, parent: nil))
    }
    
}

