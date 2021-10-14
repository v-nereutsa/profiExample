//
//  LoginInteractor.swift
//
//  Created by Владимир Нереуца on 24.01.2021.
//

import Foundation
import RxSwift
import Apollo

class LoginInteractor: LoginInteractorProtocol {
    private let networkClient: NetworkClient
    private let userManager: UserManager

    init(networkClient: NetworkClient, userManager: UserManager) {
        self.networkClient = networkClient
        self.userManager = userManager
    }
    
    func authorizeUser(username: String, password: String) -> Single<AuthorizeUserMutation.Data.LogInUser> {
        return Single<AuthorizeUserMutation.Data.LogInUser>.create { single in
            let mutation = AuthorizeUserMutation(username: username, password: password)
            
            self.networkClient.execute(mutation, completion: { response in
                if response.errors.count > 0, let error = response.errors.first {
                    single(.error(error))
                    return
                }
                if let data = response.result?.logInUser {
                    self.userManager.onUserAuthorized(token: data.tokens.userToken, refreshToken: data.tokens.refreshToken)
                    single(.success(data))
                } else {
                    single(.error(self.generateUnknownError()))
                }
            })
            return Disposables.create()
        }
    }
    
    deinit {
        print("LoginInteractor deinit")
    }
}
