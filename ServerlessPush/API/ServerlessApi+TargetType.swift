//
//  ServerlessApi+TargetType.swift
//  ServerlessPush
//
//  Created by Pritam on 2/3/21.
//

import Moya

extension ServerlessApi: TargetType {
    var apiVersion: String {
        return ""
    }
    var environmentBaseUrl: String {
        switch NetworkManager.environment {
        case .develop:
            return "" + apiVersion
        case .production:
            return "" + apiVersion
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseUrl) else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .userInfo:
            return "/userInfo"
        }
    }
    
    var method: Method {
        switch self {
        case .userInfo:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        default:
            return .requestPlain
        }
    }
    
    var contentType: String? {
        switch self {
        default:
            return "application/json"
        }
    }
    
    var headers: [String : String]? {
        var headers = [
            "Accept": "*/*",
            "Accept-Encoding": "gzip, deflate, br",
            "X-Device-Fingerprinting": "sc=24;sh=\(UIScreen.main.bounds.height);" +
                                        "sh=\(UIScreen.main.bounds.width);tz=-540",
            "Device-Type": "SmartDevice",
            "x-device-platform": "IOS"
        ]
        
        if let contentType = contentType {
            headers["Content-Type"] = contentType
        }
        
        return headers
    }
}
