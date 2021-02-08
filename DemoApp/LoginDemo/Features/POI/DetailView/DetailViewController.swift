//
//  DetailViewController.swift
//  LoginDemo
//
//  Created by Ferran Pujol Camins on 23/04/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class DetailViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    private var rootView: DetailView
    private var output: Driver<DetailView.Model>
    
    private let backButton: UIBarButtonItem
    
    init(rootView: DetailView, output: Driver<DetailView.Model>, backButton: UIBarButtonItem) {
        self.rootView = rootView
        self.output = output
        self.backButton = backButton
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = backButton
        setupBindings()
    }
    
    private func setupBindings() {
        output.drive(rootView.rx.inputs)
            .disposed(by: disposeBag)
    }
}
