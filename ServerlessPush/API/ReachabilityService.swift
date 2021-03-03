//
//  ReachabilityService.swift
//  ServerlessPush
//
//  Created by Pritam on 2/3/21.
//

import Reachability
import RxSwift

enum ReachabilityStatus {
    case cellular
    case wifi
    case unavailable
    case none
    
    var isReachable: Bool {
        switch self {
        case .cellular, .wifi:
            return true
        default:
            return false
        }
    }
}

class ReachabilityService {
    private let reachability: Reachability
    private let reachabilitySubject: BehaviorSubject<ReachabilityStatus>
    var observable: Observable<ReachabilityStatus> {
        return reachabilitySubject.asObservable()
    }
    
    init() throws {
        
        reachability = try Reachability()
        reachabilitySubject = BehaviorSubject<ReachabilityStatus>(value: .none)
        
        let queue = DispatchQueue(label: "reachability.wificheck")
        
        reachability.whenReachable = { [weak self] _ in
            queue.async {
                switch self?.reachability.connection {
                case .wifi:
                    self?.reachabilitySubject.on(.next(.wifi))
                case .cellular:
                    self?.reachabilitySubject.on(.next(.cellular))
                default:
                    break
                }
            }
        }
        
        reachability.whenUnreachable = { [weak self] _ in
            queue.async {
                self?.reachabilitySubject.on(.next(.unavailable))
            }
        }
        
        try reachability.startNotifier()
    }
    
    deinit {
        reachability.stopNotifier()
    }
}
