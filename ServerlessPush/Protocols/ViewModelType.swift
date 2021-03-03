//
//  ViewModelType.swift
//  ServerlessPush
//
//  Created by Pritam on 27/2/21.
//

import RxCocoa
import RxFlow
import RxSwift

protocol ActivityIndicatorType {
    var isLoading: Driver<Bool> { get }
}

extension ActivityIndicatorType {
    
}

protocol ErrorSupportType {
    var errorResponse: PublishRelay<(errorResponse: AppError,
                                     requestTag: String)> { get }
}

extension ErrorSupportType {
    
}

protocol LogoutSupportType {
    func logout()
}

protocol RetrySupportType {
    func retry()
}

protocol ViewModelType: ActivityIndicatorType, ErrorSupportType, LogoutSupportType, RetrySupportType {
    var disposeBag: DisposeBag { get }
}

extension ViewModelType {
    
}

protocol ServiceType {
    associatedtype Services
    var services: Services { get set }
}

protocol ServicesViewModelType: ViewModelType, ServiceType {
    
}
