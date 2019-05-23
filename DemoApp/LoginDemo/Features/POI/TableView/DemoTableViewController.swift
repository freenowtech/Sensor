//
//  DemoTableViewController.swift
//  LoginDemo
//
//  Created by Ferran Pujol Camins on 06/11/2018.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DemoTableViewController: UIViewController {

    var coordinatorOutputs: DemoTableStore.CoordinatorOutput {
        return storeOutputs.forCoordinator
    }
    
    // MARK: Private

    private var rootView = DemoTableView()
    private let refreshButton = UIButton(type: .roundedRect)

    private let disposeBag = DisposeBag()

    override func loadView() {
        self.view = rootView
    }

    private lazy var storeOutputs = DemoTableStore.makeOutputs(inputs: (
        refreshTapped: refreshButton.rx.tap.asSignal(),
        cellSelected: rootView.outputs
    ))
    
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
        storeOutputs.forView
            .drive(rootView.rx.inputs)
            .disposed(by: disposeBag)
    }
}
