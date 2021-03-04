//
//  InitializationViewModel.swift
//  ServerlessPush
//
//  Created by Pritam on 3/3/21.
//

import RxFlow
import RxCocoa

class InitializationViewModel: BaseViewModel, ServiceType {
    typealias Services = AppStateService
    var services: Services?
    
    override var isLoading: Driver<Bool> {
        progressRelay.asDriver()
    }
    
    private let progressRelay = BehaviorRelay<Bool>(value: false)
    
    override init() {
        
    }
    
    func checkUserSessionStatus() {
        if !(services?.isUserloggedIn ?? false) {
            completeInitialization(next: .welcome)
        } else {
            completeInitialization(next: .home)
        }
    }
    
    func completeInitialization(next: NextToInitialization) {
        steps.accept(AppStep.completeInitialization(next: next))
    }
}
