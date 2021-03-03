//
//  AppError.swift
//  ServerlessPush
//
//  Created by Pritam on 27/2/21.
//

import Foundation

struct AppError: Codable, Equatable {
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        return lhs.type == rhs.type &&
            lhs.errorID == rhs.errorID &&
            lhs.message == rhs.message
    }
    
    let type: ErrorType
    let errorID: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case errorID = "errorId"
        case message
    }
    
    enum ErrorType: String, Codable {
        case validation
        case exception
        case unknown
        case network
        case http
    }
    
    static var sessionExpired = AppError(
        type: .network,
        errorID: "ERR001",
        message: L10n.Error.sessionExpiredMessage
    )

    static var networkError = AppError(
        type: .network,
        errorID: "ERR002",
        message: L10n.Error.networkErrorMessage
    )
    
    static var unknown = AppError(
        type: .unknown,
        errorID: "ERR003",
        message: L10n.Error.unknownErrorMessage
    )
}
