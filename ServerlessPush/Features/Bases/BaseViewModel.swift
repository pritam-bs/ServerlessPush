//
//  BaseViewModel.swift
//  ServerlessPush
//
//  Created by Pritam on 1/3/21.
//

import RxFlow
import RxCocoa
import RxSwift

class BaseViewModel: Stepper, ViewModelType {
    var disposeBag = DisposeBag()
    
    var activity: ActivityIndicator = ActivityIndicator()
    var isLoading: Driver<Bool> {
        activity.asDriver()
    }
    
    var errorResponse = PublishRelay<(errorResponse: AppError, requestTag: String)>()
    
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    
    func logout() {
        
    }
    
    func retry() {
        
    }
}
