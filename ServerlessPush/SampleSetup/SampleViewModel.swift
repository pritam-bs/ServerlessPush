//
//  BaseViewModel.swift
//  ServerlessPush
//
//  Created by Pritam on 28/2/21.
//

import RxFlow
import RxCocoa
import RxSwift

class SampleViewModel: BaseViewModel {
    override var isLoading: Driver<Bool> {
        progressRelay.asDriver()
    }
    
    private let progressRelay = BehaviorRelay<Bool>(value: false)
    
    override init() {
        
    }
    
    func showActivityIndicator() {
        progressRelay.accept(true)
    }
    
    func hideActivityIndicator() {
        progressRelay.accept(false)
    }
    
    func showError() {
        errorResponse.accept((errorResponse: AppError.sessionExpired, requestTag: "sessionExpired"))
    }
}
