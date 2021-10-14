//
//  LoginViewState.swift
//
//  Created by Владимир Нереуца on 24.01.2021.
//

import Foundation

struct LoginViewState {
    var usernameInput: String = ""
    var passwordInput: String = ""
        
    var errors = LoginErrors()
    var payload: LoginPayload? = nil
    
    var isLoading: Bool = false
    struct LoginPayload {}
}
