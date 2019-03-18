//
//  DemoTableViewController.swift
//  LoginDemoRxRedux
//
//  Created by Ferran Pujol Camins on 06/11/2018.
//  Copyright © 2018 Mounir Dellagi. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DemoTableViewController: UIViewController {

    private var rootView = DemoTableView()
    let refreshButton = UIButton(type: .roundedRect)

    let service = GOTService()

    private let disposeBag = DisposeBag()
    
    private lazy var feedbackViewModel = {
        DemoTableStore(refreshButton: refreshButton.rx.tap.asSignal())
    }()

    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupBindings()
        self.title = "Rx TableView Example"
    }

    private func setupNavBar() {
        refreshButton.setTitle("Refresh", for: .normal)
        let barButton = UIBarButtonItem(customView: refreshButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    private func setupBindings() {
        feedbackViewModel.output
            .drive(rootView.rx.inputs)
            .disposed(by: disposeBag)
    }
}
