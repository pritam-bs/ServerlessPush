//
//  WelcomeFlow.swift
//  ServerlessPush
//
//  Created by Pritam on 3/3/21.
//

import UIKit
import RxFlow

class WelcomeFlow: Flow {
    var root: Presentable { return rootController }

    private lazy var rootController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = false
        return navigationController
    }()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .welcome:
            return navigateToWelcome()
        case .completeWelcome:
            return completeWelcome()
        default:
            return .none
        }
    }

    private func navigateToWelcome() -> FlowContributors {
        let viewModel = WelcomeViewModel()
        let controller = WelcomeViewController.instantiate(withViewModel: viewModel)
        rootController.replaceViewController(controller, animated: true)
        return FlowContributors.one(
            flowContributor: FlowContributor.contribute(
                withNextPresentable: controller,
                withNextStepper: viewModel)
        )
    }
    
    private func completeWelcome() -> FlowContributors {
        return FlowContributors.end(forwardToParentFlowWithStep: AppStep.completeWelcome)
    }
}
