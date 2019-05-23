//
//  DetailCoordinator.swift
//  LoginDemo
//
//  Created by Adrian Zdanowicz on 07/05/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import RxSwift

class DetailCoordinator: BaseCoordinator {
    
    override func start() -> Observable<Identifier> {
        rootViewController.navigationController?.pushViewController(presentingViewController, animated: true)
        return navigationOutput
            .flatMap { [weak self] navigation -> Observable<Identifier> in
                guard let self = self else { return .empty() }
                switch navigation {
                case .pop:
                    self.rootViewController.navigationController?.popViewController(animated: true)
                    return Observable.just(self.path)
                default:
                    return .empty()
                }
        }
    }
    
}

