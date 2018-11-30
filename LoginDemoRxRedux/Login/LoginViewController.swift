//
//  ViewController.swift
//  LoginDemoRxRedux
//
//  Created by Mounir Dellagi on 13.02.18.
//  Copyright © 2018 Mounir Dellagi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class LoginViewController: UIViewController {

    private let disposeBag = DisposeBag()

    private var rootView = LoginView()

    private lazy var errorAlert: RxAlert = {
        let okAction =  RxAlertAction.init(title: "OK", style: .cancel, result: .succeedAction)
        return UIAlertController
            .rx_alert(title: "An unowned Error occured",
                      message: "¡Disculpen las molestias!",
                      actions: [okAction])
    }()

    private lazy var feedbackViewModel: LoginStore = {
        return LoginStore(inputs: rootView.outputs, alertInput: errorAlert.signal)
    }()

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    private func setupBindings() {

        feedbackViewModel.output
            .drive(rootView.rx.inputs)
            .disposed(by: disposeBag)

        // This should not be here but handled by the router in a perfect world!
        feedbackViewModel.output
            .drive(onNext: { [unowned self] model in
                switch model.state {
                case .loggedIn:
                    let controller = DemoTableViewController()
                    let nc = UINavigationController(rootViewController: controller)
                    self.present(nc, animated: true, completion: nil)
                case .loginFailed:
                    self.present(self.errorAlert.alert, animated: true, completion: nil)

                default: break
                }
            })
            .disposed(by: disposeBag)
    }
}
