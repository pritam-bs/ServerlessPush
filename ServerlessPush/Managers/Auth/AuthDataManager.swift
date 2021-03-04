//
//  AuthDataManager.swift
//  ServerlessPush
//
//  Created by Pritam on 3/3/21.
//

import RxFlow
import RxSwift
import RxCocoa
import AppAuth
import Keys

enum AuthEnvironment {
    case develop
    case production
}

class AuthDataManager {
    #if ENV_DEBUG
    static let environment: AuthEnvironment = .develop
    #else
    static let environment: AuthEnvironment = .production
    #endif
    
    private var redirectUri: String {
        switch AuthDataManager.environment {
        case .develop:
            return "https://serverless-universal-link-host.web.app/appid_callback_deep_link"
        case .production:
            return ""
        }
    }
    private var issuerUrl: String {
        switch AuthDataManager.environment {
        case .develop:
            return "https://jp-tok.appid.cloud.ibm.com/oauth/v4/6cc10eac-0c20-4d5b-834d-7801c7f20565"
        case .production:
            return ""
        }
    }
    private var clientId: String {
        switch AuthDataManager.environment {
        case .develop:
            return "fd921de1-5d88-417f-86b8-73bf850eef51"
        case .production:
            return ""
        }
    }
    
    private var clientSecret: String {
        let keys = ServerlessPushAppKeys()
        switch AuthDataManager.environment {
        case .develop:
            return keys.appIDClientSecretDevelop
        case .production:
            return ""
        }
    }
    
    var authState: OIDAuthState?
    
    func getAuthenticationRequest(completion: @escaping (OIDAuthorizationRequest?) -> Void) {
        self.getConfiguration { [weak self] (configuration) in
            guard let self = self else {
                completion(nil)
                return
            }
            
            if let configuration = configuration {
                guard let redirectUri = URL(string: self.redirectUri) else {
                    completion(nil)
                    return
                }
                
                // builds authentication request
                let request = OIDAuthorizationRequest(
                    configuration: configuration,
                    clientId: self.clientId,
                    clientSecret: self.clientSecret,
                    scopes: [OIDScopeOpenID, OIDScopeProfile],
                    redirectURL: redirectUri,
                    responseType: OIDResponseTypeCode,
                    additionalParameters: nil)
                completion(request)
            }
        }
    }
    
    func getConfiguration(completion: @escaping (OIDServiceConfiguration?) -> Void) {
        guard let issuer = URL(string: self.issuerUrl) else {
            log.debug("Error creating URL for : \(self.issuerUrl)")
            completion(nil)
            return
        }
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
            guard let config = configuration else {
                log.debug("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                completion(nil)
                return
            }
            log.debug("Got configuration: \(config)")
            
            completion(config)
        }
    }
    
    func getEndSessionRequest(completion: @escaping (OIDEndSessionRequest?) -> Void) {
        guard let issuer = URL(string: self.issuerUrl) else {
            log.debug("Error creating URL for : \(self.issuerUrl)")
            completion(nil)
            return
        }
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { [weak self] configuration, error in
            
            guard let configuration = configuration else {
                log.debug("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                completion(nil)
                return
            }
            
            let authState = self?.getAuthState()
            
            guard let idToken = authState?.lastTokenResponse?.idToken else {
                completion(nil)
                return
            }
            
            guard let self = self else {
                completion(nil)
                return
            }
            
            guard let redirectUri = URL(string: self.redirectUri) else {
                log.debug("Error creating URL for : \(self.redirectUri)")
                completion(nil)
                return
            }
            
            let request = OIDEndSessionRequest(
                configuration: configuration,
                idTokenHint: idToken,
                postLogoutRedirectURL: redirectUri,
                additionalParameters: nil)
            completion(request)
        }
    }
    
    func doEndSessionApiCall(completion: @escaping (Bool) -> Void) {
        let authState = self.getAuthState()
        guard let endSessionEndpoint =
                authState?
                .lastAuthorizationResponse
                .request
                .configuration
                .discoveryDocument?
                .endSessionEndpoint else {
            log.debug("End session endpoint not declared in discovery document")
            completion(false)
            return
        }

        log.debug("End session endpoint: \(endSessionEndpoint.absoluteString)")
               
        guard let refressToken = authState?.lastTokenResponse?.refreshToken else {
            completion(false)
            return
        }
        
        let clientId = self.clientId
        let clientSecret = self.clientSecret
        
        var urlRequest = URLRequest(url: endSessionEndpoint)
        urlRequest.allHTTPHeaderFields = ["content-type": "application/x-www-form-urlencoded"]
        
        urlRequest.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "refresh_token": refressToken
        ]
        
        urlRequest.httpBody = parameters.percentEncoded()

        let task = URLSession.shared.dataTask(with: urlRequest) {[weak self] _, response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    log.debug("HTTP request failed \(error?.localizedDescription ?? "ERROR")")
                    completion(false)
                    return
                }

                guard let response = response as? HTTPURLResponse else {
                    log.debug("Non-HTTP response")
                    completion(false)
                    return
                }
                log.debug("HTTPURLResponse: \(response.statusCode)")
                
                if response.statusCode == HTTPStatusCodes.noContent.rawValue {
                    self?.saveAuthState(authState: nil)
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        task.resume()
    }

    func saveAuthState(authState: OIDAuthState?) {
        self.authState = authState
        SessionManager.shared.writeAuthInfo(authState: authState)
    }

    func getAuthState() -> OIDAuthState? {
        return try? SessionManager.shared.loadAuthState()
    }
}
