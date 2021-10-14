//
//  LoginViewModelProtocol.swift
//
//  Created by Владимир Нереуца on 24.01.2021.
//

import Foundation
import RxCocoa

protocol LoginViewModelProtocol {
    var viewState: BehaviorRelay<LoginViewState> {get set}
    var viewEvents: BehaviorRelay<LoginViewEvents?> {get set}
    
    func authorizeUser()
    func onTextFieldEdited(text: String?, type: LoginTextFieldType)
}
