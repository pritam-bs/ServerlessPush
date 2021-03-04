//
//  SceneDelegate.swift
//  ServerlessPush
//
//  Created by Pritam on 26/2/21.
//

import UIKit
import SwiftyBeaver
import IQKeyboardManagerSwift
import RxFlow
import RxSwift
import AppAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var window: UIWindow?
    let disposeBag = DisposeBag()
    let flowCoordinator = FlowCoordinator()
    var appFlow: AppFlow!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let appWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
        appWindow.windowScene = windowScene
        appWindow.makeKeyAndVisible()
        
        flowCoordinator.rx.didNavigate
            .subscribe(onNext: { (flow, step) in
                log.debug("[FlowCoordinator] App has been navigated.\n  Flow: \(flow)\n  Step: \(step)")
            })
            .disposed(by: disposeBag)
        
        appFlow = AppFlow(window: appWindow)
        
        let compositeStepper = CompositeStepper(
            steppers: [OneStepper(withSingleStep: AppStep.initialization)]
        )
        flowCoordinator.coordinate(flow: appFlow, with: compositeStepper)
        
        window = appWindow
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                if let authorizationFlow = self.currentAuthorizationFlow, authorizationFlow.resumeExternalUserAgentFlow(with: url) {
                    self.currentAuthorizationFlow = nil
                }
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        self.handleDeepLinkUrl(url: url)
    }
    
    func handleDeepLinkUrl(url: URL) {
        let receivedUrlComponent = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let queryItems = receivedUrlComponent?.queryItems
        let path = receivedUrlComponent?.path
        let host = receivedUrlComponent?.host
        
        var appIdCallBackUrlComponents = URLComponents()
        appIdCallBackUrlComponents.scheme = "https"
        appIdCallBackUrlComponents.host = host
        if let path = path {
            appIdCallBackUrlComponents.path = path
        }
        appIdCallBackUrlComponents.queryItems = queryItems
        log.debug(appIdCallBackUrlComponents)
        
        guard let appIdCallBackUrl = appIdCallBackUrlComponents.url else { return }
        
        if let authorizationFlow = self.currentAuthorizationFlow, authorizationFlow.resumeExternalUserAgentFlow(with: appIdCallBackUrl) {
            self.currentAuthorizationFlow = nil
        }
    }
}

