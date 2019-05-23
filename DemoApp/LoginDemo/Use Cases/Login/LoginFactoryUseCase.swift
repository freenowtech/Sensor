//
//  LoginFactoryUseCase.swift
//  LoginDemo
//
//  Created by Adrian Zdanowicz on 18/04/2019.
//  Copyright © 2019 Mounir Dellagi. All rights reserved.
//

import Foundation
import UIKit.UIViewController
import RxSwift
import RxCocoa

extension UseCase {
    
    static func createLoginCoordinatorPayload(parent: BaseCoordinator?) -> (payload: CoordinatorPayload, alert: RxAlert) {
        let rootView = LoginView()
        let errorAlert = createErrorAlert()
        let outputs = LoginStore.makeOutputs(inputs: rootView.outputs, alertInput: errorAlert.signal)
        let viewController = LoginViewController(output: outputs.viewDriver, rootView: rootView)
        return (CoordinatorPayload(viewController: viewController, navigationOutput: outputs.navigationDriver, path: Identifier.login, parent: parent),
                errorAlert)
    }
    
    private static func createErrorAlert() -> RxAlert {
        let okAction =  RxAlertAction.init(title: "OK", style: .cancel, result: .succeedAction)
        return UIAlertController
            .rx_alert(title: "An unowned Error occured",
                      message: "¡Disculpen las molestias!",
                      actions: [okAction])
    }
}
