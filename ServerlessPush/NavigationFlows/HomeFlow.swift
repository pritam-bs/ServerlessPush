//
//  HomeFlow.swift
//  ServerlessPush
//
//  Created by Pritam on 3/3/21.
//

import UIKit
import RxFlow

class HomeFlow: Flow {
    var root: Presentable {
        return rootController
    }
    
    private lazy var rootController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        return navigationController
    }()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .home:
            return navigateToHome()
        default:
            return .none
        }
    }
    
    private func navigateToHome() -> FlowContributors {
        let viewModel = HomeViewModel()
        let controller = HomeViewController.instantiate(
            withViewModel: viewModel
        )
        rootController.pushViewController(controller, animated: true)
        return FlowContributors.one(
            flowContributor: FlowContributor.contribute(
                withNextPresentable: controller,
                withNextStepper: viewModel
            )
        )
    }
}
