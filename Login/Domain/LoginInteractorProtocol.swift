//
//  LoginInteractorProtocol.swift
//
//  Created by Владимир Нереуца on 24.01.2021.
//

import Foundation
import RxSwift

protocol LoginInteractorProtocol: CommonInteractorProtocol {
    func authorizeUser(username: String, password: String) -> Single<AuthorizeUserMutation.Data.LogInUser>
}
