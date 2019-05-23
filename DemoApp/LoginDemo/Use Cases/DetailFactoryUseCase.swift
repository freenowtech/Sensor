//
//  DetailFactoryUseCase.swift
//  LoginDemo
//
//  Created by Adrian Zdanowicz on 07/05/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation
import UIKit.UIViewController
import RxSwift
import RxCocoa

extension UseCase {
    
    static func createDetailCoordinatorPayload(poi: POI, parent: BaseCoordinator?) -> CoordinatorPayload {
        let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        let view = DetailView(poi, backTapped: button.rx.tap.asSignal())
        let outputs = DetailStore.makeOutputs(inputs: view.outputs)
        let vc = DetailViewController(rootView: view, output: outputs.viewDriver, backButton: button)
        return CoordinatorPayload(viewController: vc, navigationOutput: outputs.navigationDriver, path: Identifier.detail, parent: parent)
    }
    
}
