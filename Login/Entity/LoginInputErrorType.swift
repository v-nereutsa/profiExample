//
//  LoginInputErrorType.swift
//
//  Created by Владимир Нереуца on 30.01.2021.
//

import Foundation

enum LoginInputErrorType: String, CaseIterable {
    case USERNAME_ERROR = "LOGIN_NOT_EXISTS"
    case PASSWORD_ERROR = "WRONG_PASSWORD"
    case AUTH_DATA_ERROR
    
    var description: String {
        switch self {
        case .USERNAME_ERROR: return "Введите логин"
        case .PASSWORD_ERROR: return "Введите пароль"
        case .AUTH_DATA_ERROR: return "Введите логин и пароль"
        }
    }
    
    static func getType(type: String) -> LoginInputErrorType? {
        return self.allCases.first{ "\($0)" == type }
    }
}
