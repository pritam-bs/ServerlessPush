//
//  InitializationViewController.swift
//  ServerlessPush
//
//  Created by Pritam on 3/3/21.
//

import Reusable

class InitializationViewController: BaseViewController,
                                    StoryboardSceneBased,
                                    ViewType {
    static var sceneStoryboard = UIStoryboard(name: StoryboardScene.Initialization.storyboardName, bundle: nil)
    
    typealias ViewModel = InitializationViewModel
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.checkUserSessionStatus()
    }
    
    func setupUserInterface() {
        
    }
    
    func bindWithViewModel() {
        
    }
}
