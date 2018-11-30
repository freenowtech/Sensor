//
//  DemoTableViewCell.swift
//  LoginDemoRxRedux
//
//  Created by Fabio Cuomo on 12/11/2018.
//  Copyright © 2018 Mounir Dellagi. All rights reserved.
//

import UIKit
import AlamofireImage

final class DemoTableViewCell: UITableViewCell {
    
    static let Identifier = "DemoTableViewCellIdentifier"
    private var shouldUpdateContraints: Bool = true
    
    private let titleTextLabel: UILabel = {
        var titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.numberOfLines = 1
        return titleLabel
    }()
    private let descriptionTextLabel: UILabel = {
        var titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    private let cellImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.backgroundColor = RandomColorHelper.randomColorFromPalette()
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupCell() {
        contentView.addSubview(titleTextLabel)
        contentView.addSubview(descriptionTextLabel)
        contentView.addSubview(cellImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cellImageView.layer.masksToBounds = true
        cellImageView.layer.cornerRadius = 4
        cellImageView.layer.borderColor = UIColor.gray.cgColor
        cellImageView.layer.borderWidth = 1.0
    }
    
    override func updateConstraints() {
        if shouldUpdateContraints {
            cellImageView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview().offset(10)
                make.width.height.equalTo(30)
            }
            titleTextLabel.snp.makeConstraints { make in
                make.top.equalTo(cellImageView.snp.top).offset(-2)
                make.leading.equalToSuperview().offset(50)
                make.trailing.equalToSuperview().offset(10)
            }
            descriptionTextLabel.snp.makeConstraints { make in
                make.top.equalTo(titleTextLabel.snp.bottom)
                make.leading.equalTo(titleTextLabel)
                make.trailing.equalToSuperview().offset(10)
                make.bottom.equalTo(cellImageView.snp.bottom)
            }
            shouldUpdateContraints = false
        }
        super.updateConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleTextLabel.text = ""
        descriptionTextLabel.text = ""
        cellImageView.image = nil
    }
    
    func configure(with model: DemoCellModel) {
        titleTextLabel.text = model.title
        descriptionTextLabel.text = model.description
        if let imageURL = model.imagePath,
            let url = URL(string: "https://api.got.show" + imageURL) {
            cellImageView.af_setImage(withURL: url)
        }
        updateConstraints()
    }
}
