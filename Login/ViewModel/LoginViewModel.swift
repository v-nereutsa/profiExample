//
//  LoginViewModel.swift
//
//  Created by Владимир Нереуца on 24.01.2021.
//

import Foundation
import RxCocoa
import Apollo

class LoginViewModel: LoginViewModelProtocol {
    
    var viewState: BehaviorRelay<LoginViewState> = BehaviorRelay(value: LoginViewState())
    var viewEvents: BehaviorRelay<LoginViewEvents?> = BehaviorRelay(value: nil)
    
    private let interactor: LoginInteractorProtocol
    
    init(interactor: LoginInteractorProtocol) {
        self.interactor = interactor
    }
    
    func authorizeUser() {
        if (!checkFields()) { return }
        let single = interactor.authorizeUser(username: viewState.value.usernameInput, password: viewState.value.passwordInput)
        let _ = single.subscribe(onSuccess: { [weak self] response in
            self?.viewEvents.accept(LoginViewEvents.authorizationSuccessful)
        }, onError: { [weak self] error in
            self?.mapError(error: error)
        })
    }
    
    
    func onTextFieldEdited(text: String?, type: LoginTextFieldType) {
        var state = viewState.value
        let input = text ?? ""
        switch type {
        case .login:
            state.usernameInput = input
            switch state.errors.inputError?.type {
            case .AUTH_DATA_ERROR:
                let error = LoginInputError(type: .PASSWORD_ERROR, message: LoginInputErrorType.PASSWORD_ERROR.description)
                state.errors.inputError = error
            case .USERNAME_ERROR:
                state.errors.inputError = nil
            default:
                break
            }
        case .password:
            state.passwordInput = input
            switch state.errors.inputError?.type {
            case .AUTH_DATA_ERROR:
                let error = LoginInputError(type: .USERNAME_ERROR, message: LoginInputErrorType.USERNAME_ERROR.description)
                state.errors.inputError = error
            case .PASSWORD_ERROR:
                state.errors.inputError = nil
            default:
                break
            }
        }
        viewState.accept(state)
    }
    
    
    private func mapError(error: Error) {
        var state = viewState.value
        state.isLoading = false
        guard let error = (error as? ResponseError) else {
            state.errors.defaultError = .SOMETHING_WENT_WRONG_ERROR
            viewState.accept(state)
            return
        }
        
        switch LoginInputErrorType(rawValue: error.type) {
        case .USERNAME_ERROR:
            let error = LoginInputError(type: .USERNAME_ERROR, message: error.message)
            state.errors.inputError = error
        case .PASSWORD_ERROR:
            let error = LoginInputError(type: .PASSWORD_ERROR, message: error.message)
            state.errors.inputError = error
        default:
            switch DefaultErrorType.getType(type: error.type) {
            case .INTERNET_CONNECTION_ERROR:
                state.errors.defaultError = .INTERNET_CONNECTION_ERROR
            default:
                state.errors.defaultError = .SOMETHING_WENT_WRONG_ERROR
            }
        }
        
        viewState.accept(state)
    }
    
    
    private func checkFields() -> Bool {
        var state = viewState.value
        if state.passwordInput == "" && state.usernameInput == "" {
            let error = LoginInputError(type: .AUTH_DATA_ERROR, message: LoginInputErrorType.AUTH_DATA_ERROR.description)
            state.errors.inputError = error
            viewState.accept(state)
            return false
        }
        if state.passwordInput == "" {
            let error = LoginInputError(type: .PASSWORD_ERROR, message: LoginInputErrorType.PASSWORD_ERROR.description)
            state.errors.inputError = error
            viewState.accept(state)
            return false
        }
        if state.usernameInput == "" {
            let error = LoginInputError(type: .USERNAME_ERROR, message: LoginInputErrorType.USERNAME_ERROR.description)
            state.errors.inputError = error
            viewState.accept(state)
            return false
        }
        state.isLoading = true
        state.errors.inputError = nil
        viewState.accept(state)
        return true
    }
    
    deinit {
        print("LoginViewModel deinit")
    }
}
