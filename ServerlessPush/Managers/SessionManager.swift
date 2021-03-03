//
//  SessionManager.swift
//  ServerlessPush
//
//  Created by Pritam on 2/3/21.
//

import KeychainAccess
import RxCocoa
import RxSwift
import Alamofire
import AppAuth
import Moya

class SessionManager {
    static let shared = SessionManager()
    var session: Session {
        return sessionManager
    }
    
    private let authenticator: AuthAuthenticator
    private let interceptor: AuthenticationInterceptor<AuthAuthenticator>
    private let sessionManager: Session
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "")
    private enum Key: String {
        case authState
    }
    
    private var disposeBag = DisposeBag()
    
    private init() {
        authenticator = AuthAuthenticator()
        interceptor = AuthenticationInterceptor(authenticator: authenticator)
        let configuration = URLSessionConfiguration.ephemeral
        sessionManager = Session(configuration: configuration, interceptor: interceptor)
        addCredential()
    }
    
    func loadAuthState() throws -> OIDAuthState? {
        if let authStateData = try keychain.getData(Key.authState.rawValue) {
            let authState = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(authStateData) as? OIDAuthState
            return authState
        }
        return nil
    }
    
    func writeAuthInfo(authState: OIDAuthState?) {
        guard let authState = authState else {
            removeAuthState()
            return }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: false)
            try keychain.set(data, key: Key.authState.rawValue)
        } catch {
            log.debug("Couldn't write auth state")
        }

        self.addCredential()
    }
    
    func removeAuthState() {
        do {
            try keychain.remove(Key.authState.rawValue)
        } catch let ex {
            log.error("[SessingManager] Remove auth state failed: \n\(ex.localizedDescription)")
        }

        self.removeCredential()
    }
    
    var accessToken: String? {
        do {
            let authState = try loadAuthState()
            let token = authState?.lastTokenResponse?.accessToken
            return token
        } catch let error {
            log.debug("[SessingManager] Read access token failed: \n\(error.localizedDescription)")
        }
        return nil
    }

    var refreshToken: String? {
        do {
            let authState = try loadAuthState()

            let token = authState?.lastTokenResponse?.refreshToken
            return token
        } catch let error {
            log.debug("[SessingManager] Read refresh token failed: \n\(error.localizedDescription)")
        }
        return nil
    }
    
    var isTokenValid: Bool {
        do {
            let authState = try loadAuthState()

            let isValid = authState?.isAuthorized
            return isValid ?? false
        } catch let error {
            log.debug("[SessingManager] Read authorization state failed: \n\(error.localizedDescription)")
        }

        return false
    }
    
    private var expiry: Date? {
        do {
            let authState = try loadAuthState()
            let expiry = authState?.lastTokenResponse?.accessTokenExpirationDate
            return expiry
        } catch let error {
            log.debug("[SessingManager] Read expiry failed: \n\(error.localizedDescription)")
        }
        return nil
    }
    
    private var expired: Bool {
        if let expiry = expiry {
            return expiry.isInPast
        }
        return true
    }
    
    private func addCredential() {
        if let accessToken = self.accessToken,
            let refreshToken = self.refreshToken,
            let expiry = self.expiry {
            let credential = AuthCredential(accessToken: accessToken,
                                            refreshToken: refreshToken,
                                            expiration: expiry)
            self.interceptor.credential = credential
        }
    }

    private func removeCredential() {
        self.interceptor.credential = nil
    }
}

struct AuthCredential: AuthenticationCredential {
    let accessToken: String
    let refreshToken: String
    let expiration: Date

    var requiresRefresh: Bool { Date(timeIntervalSinceNow: 60 * 5) > expiration }
}

class AuthAuthenticator: Authenticator {
    typealias Credential = AuthCredential
    private let session: Session = {
            let configuration = URLSessionConfiguration.default
            return Session(configuration: configuration)
        }()

    func apply(_ credential: AuthCredential, to urlRequest: inout URLRequest) {
        urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
    }

    func refresh(_ credential: AuthCredential,
                 for session: Session,
                 completion: @escaping (Result<AuthCredential, Error>) -> Void) {
        refreshTokens { (result) in
            completion(result)
        }
    }

    func didRequest(_ urlRequest: URLRequest,
                    with response: HTTPURLResponse,
                    failDueToAuthenticationError error: Error) -> Bool {
        return response.statusCode == HTTPStatusCodes.unauthorized.rawValue
    }

    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: AuthCredential) -> Bool {
        let bearerToken = HTTPHeader.authorization(bearerToken: credential.accessToken).value
        return urlRequest.headers["Authorization"] == bearerToken
    }

    private func refreshTokens(completion: @escaping (Result<AuthCredential, Error>) -> Void) {
        do {
            let sessionManager = SessionManager.shared
            let authState = try sessionManager.loadAuthState()
            if let tokenRefreshRequest = authState?.tokenRefreshRequest() {
                OIDAuthorizationService.perform(tokenRefreshRequest) { (tokenResponse, error) in
                    authState?.update(with: tokenResponse, error: error)
                    sessionManager.writeAuthInfo(authState: authState)

                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    if let accessToken = authState?.lastTokenResponse?.accessToken,
                        let refreshToken = authState?.lastTokenResponse?.refreshToken,
                        let expiration = authState?.lastTokenResponse?.accessTokenExpirationDate {
                        let credential = AuthCredential(
                            accessToken: accessToken,
                            refreshToken: refreshToken,
                            expiration: expiration)

                        completion(.success(credential))
                    }
                }
            }
        } catch let error {
            log.debug(error)
            completion(.failure(error))
        }
    }
}

private extension Date {
    var isInPast: Bool {
        let now = Date()
        return self.compare(now) == ComparisonResult.orderedAscending
    }
}
