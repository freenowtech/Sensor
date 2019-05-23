//
//  AppCoordinator.swift
//  LoginDemo
//
//  Created by Adrian Zdanowicz on 3/26/19.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//
import Foundation
import UIKit
import RxSwift

enum Identifier: String {
    case login
    case tableView
    case detail
}

// table view coordinator?
final class AppCoordinator: BaseCoordinator {

    override func start() -> Observable<Identifier> {
        return navigationOutput.flatMap { [weak self] navigation -> Observable<Identifier> in
            guard let self = self else { return .never() }
            switch navigation {
            case .login:
                return self.showLogin()
            case .detail(let poi):
                return self.showDetail(poi: poi)
            default:
                return .empty()
            }
        }
    }
    
    private func showLogin() -> Observable<Identifier> {
        let loginCoordinatorPayload = UseCase.createLoginCoordinatorPayload(parent: self)
        let loginCoordinator = LoginCoordinator(rootViewController: rootViewController, coordinatorPayload: loginCoordinatorPayload.payload, errorAlert: loginCoordinatorPayload.alert)
        return coordinate(to: loginCoordinator)
    }
    
    private func showDetail(poi: POI) -> Observable<Identifier> {
        let detailCoordinatorPayload = UseCase.createDetailCoordinatorPayload(poi: poi, parent: self)
        let detailCoordinator = DetailCoordinator(rootViewController: rootViewController, coordinatorPayload: detailCoordinatorPayload)
        return coordinate(to: detailCoordinator)
    }
    
}


