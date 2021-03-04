//
//  AppStateService.swift
//  ServerlessPush
//
//  Created by Pritam on 3/3/21.
//

import Foundation

class AppStateService {
    public var isUserloggedIn: Bool {
        if SessionManager.shared.isTokenValid {
            return true
        } else {
            return false
        }
    }
}
