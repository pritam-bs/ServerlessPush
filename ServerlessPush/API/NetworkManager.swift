//
//  NetworkManager.swift
//  ServerlessPush
//
//  Created by Pritam on 2/3/21.
//

import Moya
import RxSwift

enum ApiEnvironment {
    case develop
    case production
}

struct NetworkManager {
    #if ENV_DEBUG
    static let environment: ApiEnvironment = .develop
    #else
    static let environment: ApiEnvironment = .production
    #endif
    
    private let reachabilityService: ReachabilityService
    let provider: NetworkProvider<ServerlessApi>
    
    init(isStubbed: Bool = false) { 
        guard let reachabilityService = try? ReachabilityService()
        else { fatalError("Reachability service initialization failure")}
        
        self.reachabilityService = reachabilityService
        
        var plugins: [PluginType] = []
        #if DEBUG
        var loggerPluginConfiguration = NetworkLoggerPlugin.Configuration()
        loggerPluginConfiguration.logOptions = .verbose
        plugins.append(NetworkLoggerPlugin(configuration: loggerPluginConfiguration))
        #endif
        
        provider = NetworkProvider(
            endpointClosure: ServerlessApi.endpointClosure,
            stubClosure: isStubbed ? MoyaProvider.immediatelyStub : MoyaProvider.neverStub,
            session: SessionManager.shared.session,
            plugins: plugins,
            reachability: isStubbed ? .just(.wifi) : reachabilityService.observable
        )
    }
}
