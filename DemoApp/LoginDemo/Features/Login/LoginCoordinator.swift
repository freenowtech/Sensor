//
//  LoginCoordinator.swift
//  LoginDemo
//
//  Created by Adrian Zdanowicz on 3/26/19.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import UIKit
import RxSwift

class LoginCoordinator: BaseCoordinator {
    
    private let errorAlert: RxAlert
    
    init(rootViewController: UIViewController, coordinatorPayload: CoordinatorPayload, errorAlert: RxAlert) {
        self.errorAlert = errorAlert
        super.init(rootViewController: rootViewController, coordinatorPayload: coordinatorPayload)
    }

    override func start() -> Observable<Identifier> {
        rootViewController.present(presentingViewController, animated: false)
        return navigationOutput
            .flatMap { [weak self] navigation -> Observable<Identifier> in
            guard let self = self else { return .empty() }
            switch navigation {
            case .dismiss:
                self.presentingViewController.dismiss(animated: true)
                return Observable.just(self.path)
            case .showError:
                self.showErrorAlert()
                return .empty()
            default:
                return .empty()
            }
        }
    }

    private func showErrorAlert() {
        presentingViewController.present(self.errorAlert.alert, animated: true)
    }

}
