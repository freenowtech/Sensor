//
//  BaseCoordinator.swift
//  LoginDemo
//
//  Created by Adrian Zdanowicz on 3/26/19.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation
import UIKit.UIViewController

struct CoordinatorPayload {
    let viewController: UIViewController
    let navigationOutput: Signal<Navigation>
    let path: Identifier
    let parent: BaseCoordinator?
}

class BaseCoordinator: CustomStringConvertible {
    
    var description: String {
        var text = "\(path)"
        
        if !childCoordinators.isEmpty {
            text += " {" + childCoordinators.map { $0.description }.joined(separator: ", ") + "} "
        }
        return text
    }
    
    let rootViewController: UIViewController
    let presentingViewController: UIViewController
    let navigationOutput: Observable<Navigation>
    let path: Identifier
    
    fileprivate let uuid = UUID()
    private weak var parent: BaseCoordinator?
    private var childCoordinators = [BaseCoordinator]()
    
    init(rootViewController: UIViewController, coordinatorPayload: CoordinatorPayload) {
        self.rootViewController = rootViewController
        self.presentingViewController = coordinatorPayload.viewController
        self.navigationOutput = coordinatorPayload.navigationOutput.asObservable()
        self.path = coordinatorPayload.path
        self.parent = coordinatorPayload.parent
    }
    
    func coordinate(to coordinator: BaseCoordinator) -> Observable<Identifier> {
        store(coordinator: coordinator)
        return coordinator.start()
            .do(onNext: { [weak self] _ in self?.free(coordinator: coordinator) })
    }
    
    func start() -> Observable<Identifier> {
        fatalError("Start method should be implemented.")
    }
    
    private func store(coordinator: BaseCoordinator) {
        childCoordinators.append(coordinator)
        print("\(parent == nil ? "Coordinator 🌳: " : "")\(description)")
    }

    private func free(coordinator: BaseCoordinator) {
        childCoordinators = childCoordinators.filter { $0.uuid != coordinator.uuid }
        print("\(parent == nil ? "Coordinator 🌳: " : "")\(description)")
    }

}
