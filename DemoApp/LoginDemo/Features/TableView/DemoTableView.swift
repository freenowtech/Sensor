//
//  DemoTableView.swift
//  LoginDemoRxRedux
//
//  Created by Fabio Cuomo on 13/11/2018.
//  Copyright © 2018 Mounir Dellagi. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class DemoTableView: UIView {

    enum Model: Equatable {
        case fetchingData
        case presentingData([DemoCellModel])
        case presentingError
    }

    let disposeBag = DisposeBag()
    let characters: BehaviorSubject<[DemoCellModel]> = BehaviorSubject(value: [])

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        return table
    }()

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.hidesWhenStopped = true
        return spinner
    }()

    private let errorView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .red
        return view
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setup() {
        setupView()
        addSubviews()
        setupConstraints()
    }

    private func setupView() {
        backgroundColor = UIColor.white

        tableView.register(DemoTableViewCell.self, forCellReuseIdentifier: DemoTableViewCell.Identifier)
        tableView.rowHeight = 44

        characters.bind(to: tableView.rx.items(cellIdentifier: DemoTableViewCell.Identifier, cellType: DemoTableViewCell.self)) { row, element, cell in
            cell.configure(with: element)
            }
            .disposed(by: disposeBag)
    }

    private func addSubviews() {
        [tableView, spinner, errorView].forEach(addSubview)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        errorView.snp.makeConstraints { make in
            make.width.height.equalTo(200)
            make.center.equalToSuperview()
        }
    }
    
    fileprivate func configure(from model: Model) {
        switch model {
        case .fetchingData:
            spinner.startAnimating()
            errorView.isHidden = true
            tableView.isHidden = true

        case .presentingData(let newCharacters):
            errorView.isHidden = true
            spinner.stopAnimating()
            tableView.isHidden = false
            characters.onNext(newCharacters)

        case .presentingError:
            errorView.isHidden = false
            spinner.stopAnimating()
            tableView.isHidden = true
        }
    }
}

extension DemoTableView.Model {
    init(_ state: DemoTableStore.State) {
        switch state {
        case .fetchingData:
            self = .fetchingData
            
        case .presentingData(let newCharacters):
            self = .presentingData(newCharacters)

        case .presentingError(_):
            self = .presentingError
        }
    }
}

extension Reactive where Base: DemoTableView {
    var inputs: Binder<DemoTableView.Model> {
        return Binder(self.base) { view, viewModel in
            view.configure(from: viewModel)
        }
    }
}
