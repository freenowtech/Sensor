//
//  LoginView.swift
//  LoginDemoRxRedux
//
//  Created by Mounir Dellagi on 13.02.18.
//  Copyright © 2018 Mounir Dellagi. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class LoginView: UIView {
    struct Model: Equatable {
        let isLoginButtonEnabled: Bool
        let isPasswordHidden: Bool
        let isSpinning: Bool

        let state: LoginStore.State
    }

    struct Outputs {
        let usernameField: Signal<String>
        let passwordField: Signal<String>
        let loginButton: Signal<Void>
        let registerButton: Signal<Void>
        let showPasswordButton: Signal<Void>
    }

    // Outpus need to be lazy in order to be able to access other properties of the view.
    // Otherwise we can't make sure that those properties are already initialized when this closure runs, so the compiler complains.
    lazy var outputs: Outputs = {
        return LoginView.Outputs(usernameField: usernameTextField.rx.text.orEmpty.changed.asSignal().distinctUntilChanged(),
                                 passwordField: passwordTextField.rx.text.orEmpty.changed.asSignal().distinctUntilChanged(),
                                 loginButton: loginButton.rx.tap.asSignal(),
                                 registerButton: registerButton.rx.tap.asSignal(),
                                 showPasswordButton: showPasswordButton.rx.tap.asSignal())
    }()

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "mountain")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 48)
        label.textAlignment = .center
        let attributedString = NSMutableAttributedString(string: "travelapp")
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1), range: NSRange(location: 0, length: 6))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 6, length: 3))
        label.attributedText = attributedString
        return label
    }()
    
    private let usernameTextField: UITextField = {
        let placeholder = NSAttributedString(
            string: "Username",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])

        let usernameTextField = UITextField()
        usernameTextField.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.font = UIFont.systemFont(ofSize: 14)
        usernameTextField.textColor = UIColor.white
        usernameTextField.attributedPlaceholder = placeholder

        let paddingView = UIView(frame:
            CGRect(x: 0,
                   y: 0,
                   width: 30,
                   height: usernameTextField.frame.height))
        usernameTextField.leftView = paddingView
        usernameTextField.leftViewMode = .always

        return usernameTextField
    }()

    private let passwordTextField: UITextField = {
        let placeholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])

        let passwordTextField = UITextField()
        passwordTextField.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.font = UIFont.systemFont(ofSize: 14)
        passwordTextField.textColor = UIColor.white
        passwordTextField.attributedPlaceholder = placeholder

        let paddingView = UIView(frame:
            CGRect(x: 0,
                   y: 0,
                   width: 30,
                   height: passwordTextField.frame.height))
        passwordTextField.leftView = paddingView
        passwordTextField.leftViewMode = .always

        return passwordTextField
    }()

    private let showPasswordButton: UIButton = {
        let showPasswordButton = UIButton(type: .custom)
        return showPasswordButton
    }()

    private let loginButton: UIButton = {
        let loginButton = UIButton()

        loginButton.setTitle("Login", for: .normal)

        loginButton.setAttributedTitle(NSAttributedString(
            string: "Login",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .bold),
                NSAttributedString.Key.foregroundColor: UIColor.white])
        , for: .normal)
        loginButton.setBackgroundColor(color: UIColor.blue, forState: .normal)

        loginButton.setAttributedTitle(NSAttributedString(
            string: "Login",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .bold),
                NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            , for: .disabled)
        loginButton.setBackgroundColor(color: UIColor.gray, forState: .disabled)

        loginButton.layer.cornerRadius = 8
        loginButton.clipsToBounds = true

        return loginButton
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .custom)
        let attributedString = NSMutableAttributedString(string: "Dont have an account? Register")
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14, weight: .light), range: NSRange(location: 0, length: 22))
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 14), range: NSRange(location: 22, length: 8))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: 30))
        button.setAttributedTitle(attributedString, for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .white)
        return spinner
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setup() {
        addSubviews()
        setupConstraints()
    }

    private func addSubviews() {
        [backgroundImageView, headerLabel, usernameTextField, passwordTextField, showPasswordButton, loginButton, registerButton, spinner, spinner].forEach(addSubview)
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(80)
        }
        usernameTextField.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(280)
            make.centerX.equalToSuperview()
            make.top.equalTo(headerLabel.snp.bottom).offset(100)
        }
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(usernameTextField.snp.width)
            make.centerX.equalToSuperview()
            make.top.equalTo(usernameTextField.snp.bottom).offset(20)
        }
        showPasswordButton.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.leading.equalTo(passwordTextField).offset(7)
            make.centerY.equalTo(passwordTextField)
        }
        loginButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.width.equalTo(usernameTextField.snp.width)
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
        }
        registerButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(loginButton.snp.bottom).offset(20)
        }
        spinner.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(registerButton.snp.bottom)
        }
    }

    fileprivate func configure(from model: LoginView.Model) {
        passwordTextField.isSecureTextEntry = model.isPasswordHidden
        let lockImage = model.isPasswordHidden ? UIImage(named: "unlock") : UIImage(named: "lock")
        showPasswordButton.setImage(lockImage, for: .normal)

        loginButton.isEnabled = model.isLoginButtonEnabled

        if model.isSpinning {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
    }
}

extension Reactive where Base: LoginView {
    var inputs: Binder<LoginView.Model> {
        return Binder(self.base) { view, loginState in
            view.configure(from: loginState)
        }
    }
}
