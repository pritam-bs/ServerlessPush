//
//  ViewType.swift
//  ServerlessPush
//
//  Created by Pritam on 27/2/21.
//

import RxSwift
import NVActivityIndicatorView
import Reusable

protocol ActivityIndicatorViewType {
    func startActivityIndicator()
    func stopActivityIndicator()
}

protocol ErrorSupportViewType {
    func shouldShowErrorDialog(errorResponse: AppError,
                               requestTag: String) -> Bool
    func showErrorAlert(appError: AppError,
                        action: @escaping (ErrorAlertActionType) -> Void)
}

extension ErrorSupportViewType where Self: UIViewController {
    
}

protocol ViewType: class, ActivityIndicatorViewType, ErrorSupportViewType {
    associatedtype ViewModel: ViewModelType
    var viewModel: ViewModel? { get set }
    var disposeBag: DisposeBag { get }
    
    func initialize()
    func setupUserInterface()
    func bindWithViewModel()
}

extension ViewType where Self: UIViewController {
    func initialize() {
        initializeUserInterface()
        initializeBinding()
    }
    
    func initializeUserInterface() {
        setupUserInterface()
    }
    
    func initializeBinding() {
        bindWithViewModel()
        viewModel?.isLoading.debug()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                if $0 {
                    self.startActivityIndicator()
                } else {
                    self.stopActivityIndicator()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel?.errorResponse
            .bind { [weak self] (response) in
                guard let self = self else { return }
                if self.shouldShowErrorDialog(
                    errorResponse: response.errorResponse,
                    requestTag: response.requestTag) {
                    self.showErrorAlert(appError: response.errorResponse)
                    { [weak self] (alertAction) in
                        switch alertAction {
                        case .logout:
                            self?.viewModel?.logout()
                        case .retry:
                            self?.viewModel?.retry()
                        case .none:
                            log.debug("No Action")
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

extension ViewType where Self: StoryboardSceneBased & UIViewController {
    static func instantiate<ViewModel> (withViewModel viewModel: ViewModel) -> Self where ViewModel == Self.ViewModel {
        let viewController = Self.instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
}

extension ViewType where Self: StoryboardSceneBased & UIViewController, ViewModel: ViewModelType & ServiceType {
    static func instantiate<ViewModel, Services> (
        withViewModel viewModel: ViewModel,
        andServices services: Services) -> Self
        where ViewModel == Self.ViewModel,
              Services == Self.ViewModel.Services {
        let viewController = Self.instantiate()
        viewController.viewModel = viewModel
        viewController.viewModel?.services = services
        return viewController
    }
}

enum ErrorAlertActionType {
    case logout
    case retry
    case none
}
