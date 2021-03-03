//
//  ServerlessApiType.swift
//  ServerlessPush
//
//  Created by Pritam on 2/3/21.
//

import Foundation

protocol ServerlessApiType {
    var auth: AuthType { get }
}

enum AuthType {
    case basic
    case bearer
    case none
}
