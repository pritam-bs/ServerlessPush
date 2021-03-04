//
//  WelcomeViewModel.swift
//  ServerlessPush
//
//  Created by Pritam on 3/3/21.
//

import RxFlow
import RxCocoa

class WelcomeViewModel: BaseViewModel {
    
    override var isLoading: Driver<Bool> {
        progressRelay.asDriver()
    }
    
    private let progressRelay = BehaviorRelay<Bool>(value: false)
    
    override init() {
        
    }
    
    func navigateNextToWelcome() {
        steps.accept(AppStep.completeWelcome)
    }
}
