//
//  WelcomeViewController.swift
//  ServerlessPush
//
//  Created by Pritam on 3/3/21.
//

import Reusable

class WelcomeViewController: BaseViewController,
                                    StoryboardSceneBased,
                                    ViewType {
    static var sceneStoryboard = UIStoryboard(name: StoryboardScene.Welcome.storyboardName, bundle: nil)
    
    typealias ViewModel = WelcomeViewModel
    var viewModel: ViewModel?
    
    private var loginViewManager: AuthViewManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    func setupUserInterface() {
        loginViewManager = AuthViewManager(controller: self)
    }
    
    func bindWithViewModel() {
        
    }
    
    @IBAction func signInAction(_ sender: Any) {
        self.loginViewManager?.doAuthWithAutoCodeExchange()
    }
}

extension WelcomeViewController: AuthViewType {
    func logoutCompletion(isSuccess: Bool) {}
    
    func loginCompletion(isSuccess: Bool, error: Error?) {
        if isSuccess {
            self.viewModel?.navigateNextToWelcome()
        }
    }
}
