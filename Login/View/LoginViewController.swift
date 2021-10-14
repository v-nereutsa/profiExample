//
//  LoginViewController.swift
//
//  Created by Владимир Нереуца on 25.10.2020.
//

import UIKit
import RxSwift

class LoginViewController: CommonViewController {
    
    @IBOutlet weak var loginLabel: HeadTitleLabel!
    @IBOutlet weak var loginButton: BaseButton!
    @IBOutlet weak var usernameTextField: UnderlinedTextField!
    @IBOutlet weak var passwordTextField: PasswordUnderlinedTextField!
    @IBOutlet weak var forgotPasswordTextView: UITextView!
    
    @IBOutlet weak var errorLabel: BottomTextFieldErrorLabel!
    
    private let viewModel: LoginViewModelProtocol
    private let disposeBag: DisposeBag
    
    
    init(viewModel: LoginViewModelProtocol, disposeBag: DisposeBag) {
        self.viewModel = viewModel
        self.disposeBag = disposeBag
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder: NSCoder) {
        fatalError("We aren't using storyboards")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        setUpRecoveryPasswordTextView()
        subscribeOnViewEvents()
        subscribeOnViewState()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameTextField.becomeFirstResponder()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        usernameTextField.setUpBottomLine()
        passwordTextField.setUpBottomLine()
    }
    
    
    @IBAction func loginButtonClick(_ sender: Any) {
        viewModel.authorizeUser()
    }
    
    private func subscribeOnViewEvents() {
        viewModel.viewEvents.asObservable().observeOn(MainScheduler.instance)
            .subscribe (onNext: { event in
                switch event {
                case .authorizationSuccessful:
                    Router.switchToMainScreen()
                case .none:
                    break
                }
            }).disposed(by: disposeBag)
    }
    
    private func subscribeOnViewState() {
        viewModel.viewState.asObservable().observeOn(MainScheduler.instance)
            .subscribe (onNext: { [weak self] switchValue in
                switch switchValue.isLoading {
                case true:
                    self?.loginButton.showLoader(userInteraction: false)
                case false:
                    self?.loginButton.hideLoader()
                }
                
                if let defaultErrors = switchValue.errors.defaultError {
                    switch defaultErrors {
                    case .INTERNET_CONNECTION_ERROR:
                        // TODO: Открыть экран с ошибкой интернет соединения и кнопкой повторить
                        break
                    case .SOMETHING_WENT_WRONG_ERROR:
                        // TODO: Открыть экран с "что-то пошло не так" и кнопкой повторить
                        break
                    }
                }
                
                switch switchValue.errors.inputError?.type {
                case .none:
                    self?.usernameTextField.isError = false
                    self?.passwordTextField.isError = false
                    self?.errorLabel.alpha = 0
                case .USERNAME_ERROR:
                    self?.usernameTextField.isError = true
                    self?.passwordTextField.isError = false
                    self?.errorLabel.text = switchValue.errors.inputError?.message
                    self?.errorLabel.alpha = 1
                case .PASSWORD_ERROR:
                    self?.usernameTextField.isError = false
                    self?.passwordTextField.isError = true
                    self?.errorLabel.text = switchValue.errors.inputError?.message
                    self?.errorLabel.alpha = 1
                case .AUTH_DATA_ERROR:
                    self?.usernameTextField.isError = true
                    self?.passwordTextField.isError = true
                    self?.errorLabel.text = switchValue.errors.inputError?.message
                    self?.errorLabel.alpha = 1
                }
            }).disposed(by: disposeBag)
    }
    
    func setUpElements() {
        usernameTextField.returnKeyType = .next
        usernameTextField.delegate = self
        usernameTextField.placeholder = "Имя пользователя"
        usernameTextField.tag = 0
        usernameTextField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange(_:)),
                                 for: .editingChanged)
        
        
        passwordTextField.returnKeyType = .done
        passwordTextField.delegate = self
        passwordTextField.placeholder = "Пароль"
        passwordTextField.tag = 1
        passwordTextField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange(_:)),
                                    for: .editingChanged)
        
        loginButton.indicator = BallSpinFadeIndicator(color: .onPrimary)
    }
    
    
    private func setUpRecoveryPasswordTextView() {
        let text = NSMutableAttributedString(string: "Забыли пароль? ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        text.addAttribute(NSAttributedString.Key.font, value: UIFont.regular.withSize(14), range: NSMakeRange(0, text.length))
        
        // Add an underline to indicate this portion of text is selectable
        let selectablePart = NSMutableAttributedString(string: "Восстановить", attributes: [NSAttributedString.Key.foregroundColor: UIColor.primary])
        selectablePart.addAttribute(NSAttributedString.Key.font, value: UIFont.bold.withSize(14), range: NSMakeRange(0, selectablePart.length))
        
        selectablePart.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: NSMakeRange(0,selectablePart.length))
        selectablePart.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor.primary, range: NSMakeRange(0, selectablePart.length))
        
        // Add an NSLinkAttributeName with a value of an url or anything else
        selectablePart.addAttribute(NSAttributedString.Key.link, value: "recoveryPassword", range: NSMakeRange(0,selectablePart.length))
        
        // Combine the non-selectable string with the selectable string
        
        text.append(selectablePart)
        
        // Set the text view to contain the attributed text
        forgotPasswordTextView.attributedText = text
        forgotPasswordTextView.textAlignment = .center
        // Set the delegate in order to use textView(_:shouldInteractWithURL:inRange)
        forgotPasswordTextView.delegate = self
    }
    
    deinit {
        print("LoginViewController deinit")
    }
    
}

// MARK: - UITextViewDelegate
extension LoginViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "recoveryPassword" {
            let destController = MainPasswordResetViewController()
            self.navigationController?.pushViewController(destController, animated: true)
        }
        return false
    }
    
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            viewModel.authorizeUser()
        }
        
        return true
    }
}

// MARK: - TextFieldDidChange
extension LoginViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case usernameTextField:
            viewModel.onTextFieldEdited(text: textField.text, type: .login)
        case passwordTextField:
            viewModel.onTextFieldEdited(text: textField.text, type: .password)
        default:
            break
        }
    }
    
}
