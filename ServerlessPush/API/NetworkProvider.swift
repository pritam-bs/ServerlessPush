//
//  NetworkProvider.swift
//  ServerlessPush
//
//  Created by Pritam on 2/3/21.
//

import Moya
import RxSwift
import Alamofire

class NetworkProvider<Target> where Target: Moya.TargetType {
    private let reachability: Observable<ReachabilityStatus>
    private let provider: MoyaProvider<Target>
    
    init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure =
            MoyaProvider<Target>.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
         session: Session = MoyaProvider<Target>.defaultAlamofireSession(),
         plugins: [PluginType] = [],
         trackInflights: Bool = false,
         reachability: Observable<ReachabilityStatus>) {
        
        self.reachability = reachability
        self.provider = MoyaProvider(endpointClosure: endpointClosure,
                                     requestClosure: requestClosure,
                                     stubClosure: stubClosure,
                                     session: session,
                                     plugins: plugins,
                                     trackInflights: trackInflights)
        }

        func request(_ token: Target) -> Observable<Moya.Response> {
            let actualRequest = provider.rx.request(token)
            return reachability
                .filter { $0.isReachable }
                .take(1)
                .flatMap { _ in
                    return actualRequest
                }
        }
}
