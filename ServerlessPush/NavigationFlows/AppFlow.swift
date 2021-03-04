//
//  AppFlow.swift
//  ServerlessPush
//
//  Created by Pritam on 3/3/21.
//

import UIKit
import RxFlow
import RxSwift

class AppFlow: Flow {
    private let rootWindow: UIWindow
    var root: Presentable { return rootWindow }
    
    init(window: UIWindow) {
        rootWindow = window
    }
    
    var homeFlow = HomeFlow()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .initialization:
            return navigateToInitialization()
        case .completeInitialization(let next):
            return onCompleteInitialization(next: next)
        case .completeWelcome:
            return navigateToHome()
        default:
            return .none
        }
    }
    
    private func navigateToInitialization() -> FlowContributors {
        let flow = InitializationFlow()
        Flows.use(flow, when: .ready) { [weak self] in
            self?.rootWindow.swapRootViewContoller(with: $0, animated: true)
        }
        
        return FlowContributors.one(
            flowContributor: FlowContributor.contribute(
                withNextPresentable: flow,
                withNextStepper: OneStepper.init(
                    withSingleStep: AppStep.initialization
                )
            )
        )
    }
    
    private func onCompleteInitialization(next: NextToInitialization) -> FlowContributors {
        switch next {
        case .welcome:
            return navigateToWelcome()
        case .home:
            return navigateToHome()
        }
    }
    
    private func navigateToWelcome() -> FlowContributors {
        let flow = WelcomeFlow()
        Flows.use(flow, when: .ready) { [weak self] in
            self?.rootWindow.swapRootViewContoller(with: $0, animated: true)
        }

        return FlowContributors.one(
            flowContributor: FlowContributor.contribute(
                withNextPresentable: flow,
                withNextStepper: OneStepper.init(withSingleStep: AppStep.welcome)
            )
        )
    }
    
    private func navigateToHome() -> FlowContributors {
        Flows.use(homeFlow, when: .ready) { [weak self] in
            self?.rootWindow.swapRootViewContoller(with: $0, animated: true)
        }

        return FlowContributors.one(
            flowContributor: FlowContributor.contribute(
                withNextPresentable: homeFlow,
                withNextStepper: OneStepper.init(withSingleStep: AppStep.home)))
    }
}
