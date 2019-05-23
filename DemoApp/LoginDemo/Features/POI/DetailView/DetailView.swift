//
//  DetailView.swift
//  LoginDemo
//
//  Created by Ferran Pujol Camins on 23/04/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class DetailView: UIView {
    
    enum Model: Equatable {
        case presentingData(UIColor)
        case exiting
    }
    
    struct Outputs {
        let buttonTapped: Signal<Void>
        let backTapped: Signal<Void>
    }
    
    lazy var outputs: Outputs = {
        return DetailView.Outputs(buttonTapped: button.rx.tap.map { _ in }.asSignal(onErrorJustReturn: ()), backTapped: backTapped)
    }()
    
    private let disposeBag = DisposeBag()
    private let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("CHANGE COLOR", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let backTapped: Signal<Void>

    init(_ poi: POI, backTapped: Signal<Void>) {
        self.backTapped = backTapped
        super.init(frame: .zero)
        setup(poi)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup(_ poi: POI) {
        backgroundColor = UIColor.lightGray
        label.text = String(poi.id)

        addSubviews()
        setupConstraints()
    }

    private func addSubviews() {
        [label, button].forEach(addSubview)
    }

    private func setupConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        button.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().offset(-24)
            make.leading.equalToSuperview().offset(24)
            make.height.equalTo(56)
        }
    }
    
    fileprivate func configure(from model: Model) {
        switch model {
        case .presentingData(let newColor):
            backgroundColor = newColor
        case .exiting: ()
        }
    }
}

extension Reactive where Base: DetailView {
    var inputs: Binder<DetailView.Model> {
        return Binder(self.base) { view, viewModel in
            view.configure(from: viewModel)
        }
    }
}
