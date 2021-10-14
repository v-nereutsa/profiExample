//
//  LoginDIPart.swift
//
//  Created by Владимир Нереуца on 24.04.2021.
//

import DITranquillity

class LoginDIPart: DIPart {
    static func load(container: DIContainer) {
        container.register(LoginInteractor.init(networkClient:userManager:))
            .as(LoginInteractorProtocol.self)
            .lifetime(.prototype)
        
        container.register(LoginViewModel.init(interactor:))
            .as(LoginViewModelProtocol.self)
            .lifetime(.prototype)
        
        container.register(LoginViewController.init(viewModel:disposeBag:))
            .lifetime(.prototype)
    }
}
