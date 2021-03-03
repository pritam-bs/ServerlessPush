//
//  ServerlessApi+ApiType.swift
//  ServerlessPush
//
//  Created by Pritam on 2/3/21.
//

import Foundation

extension ServerlessApi: ServerlessApiType {
    var auth: AuthType {
        switch self {
        default:
            return .bearer
        }
    }
}
