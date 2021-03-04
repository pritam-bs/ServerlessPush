//
//  AuthViewManager.swift
//  ServerlessPush
//
//  Created by Pritam on 3/3/21.
//

import UIKit
import Reusable
import AppAuth

protocol AuthViewType where Self: UIViewController {
    func loginCompletion(isSuccess: Bool, error: Error?)
    func logoutCompletion(isSuccess: Bool)
}

class AuthViewManager: NSObject {
    private let dataManager = AuthDataManager()
    weak private var controller: AuthViewType?
    private var authState: OIDAuthState?
    
    init(controller: AuthViewType) {
        super.init()
        self.controller = controller
    }
    
    func doAuthWithAutoCodeExchange() {
        self.setAuthState(authState: nil)
        self.dataManager.getAuthenticationRequest { (request) in
            guard let request = request else { return }
            // performs authentication request
            log.debug("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")

            
            guard let sceneDelegate = UIApplication
                    .shared
                    .connectedScenes
                    .first?
                    .delegate as? SceneDelegate else {
                log.debug("Error accessing SceneDelegate")
                return
            }
            
            guard let controller = self.controller else {
                log.debug("Error accessing view controller")
                return
            }
            
            guard let userAgentIOS = OIDExternalUserAgentIOS(presenting: controller) else {
                return
            }
            
            let userAgentSafari = OIDExternalUserAgentIOSCustomBrowser.customBrowserSafari()
            
            sceneDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, externalUserAgent: userAgentSafari) { [weak self]  authState, error in

                if let authState = authState {
                    self?.dataManager.authState = authState
                    log.debug("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
                    self?.setAuthState(authState: authState)
                    self?.controller?.loginCompletion(isSuccess: true, error: nil)
                } else {
                    log.debug("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                    self?.setAuthState(authState: nil)
                    self?.controller?.loginCompletion(isSuccess: false, error: error)
                }
            }
        }
    }
    
    func doEndSession(apiCall: Bool = true) {
        if apiCall {
            self.dataManager.doEndSessionApiCall { [weak self] (isSuccess) in
                self?.controller?.logoutCompletion(isSuccess: isSuccess)
            }
        } else {
            self.dataManager.getAuthenticationRequest { [weak self] (request) in
                guard let request = request else {
                    self?.controller?.logoutCompletion(isSuccess: false)
                    return
                }
                
                guard let sceneDelegate = UIApplication
                        .shared
                        .connectedScenes
                        .first?
                        .delegate as? SceneDelegate else {
                    log.debug("Error accessing SceneDelegate")
                    self?.controller?.logoutCompletion(isSuccess: false)
                    return
                }
                
                guard let controller = self?.controller else {
                    log.debug("Error accessing view controller")
                    self?.controller?.logoutCompletion(isSuccess: false)
                    return
                }
                
                guard let userAgent = OIDExternalUserAgentIOS(presenting: controller) else {
                    self?.controller?.logoutCompletion(isSuccess: false)
                    return
                }
                
                sceneDelegate.currentAuthorizationFlow =
                    OIDAuthorizationService
                        .present(request,
                                 externalUserAgent: userAgent,
                                 callback: { [weak self] (_, error) in
                                    if error != nil {
                                        self?.setAuthState(authState: nil)
                                        self?.controller?.logoutCompletion(isSuccess: true)
                                    } else {
                                        self?.controller?.logoutCompletion(isSuccess: false)
                                    }
                    })
            }
        }
    }

    private func loadState() {
        if let authState = self.dataManager.getAuthState() {
            self.setAuthState(authState: authState)
        }
    }

    private func setAuthState(authState: OIDAuthState?) {
        if self.authState == authState {
            return
        }
        self.authState = authState
        self.authState?.stateChangeDelegate = self
        self.dataManager.saveAuthState(authState: authState)
    }
}

// MARK: OIDAuthState Delegate
extension AuthViewManager: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {

    func didChange(_ state: OIDAuthState) {
        self.dataManager.saveAuthState(authState: state)
    }

    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        log.debug("Received authorization error: \(error)")
    }
}

