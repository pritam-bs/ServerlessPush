//
//  ServerlessApi+Testing.swift
//  ServerlessPush
//
//  Created by Pritam on 2/3/21.
//

import Moya

extension ServerlessApi {
    var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
    
    static var endpointClosure = { (target: ServerlessApi) -> Endpoint in
        var statusCode = 200
        switch target {
        default:
            break
        }

        return Endpoint(
            url: URL(target: target).absoluteString,
            sampleResponseClosure: { .networkResponse(statusCode, target.sampleData) },
            method: target.method,
            task: target.task,
            httpHeaderFields:
            target.headers
        )
    }
}
