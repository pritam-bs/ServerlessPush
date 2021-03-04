//
//  HomeViewController.swift
//  ServerlessPush
//
//  Created by Pritam on 3/3/21.
//

import Reusable

class HomeViewController: BaseViewController,
                                    StoryboardSceneBased,
                                    ViewType {
    static var sceneStoryboard = UIStoryboard(name: StoryboardScene.Home.storyboardName, bundle: nil)
    
    typealias ViewModel = HomeViewModel
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    func setupUserInterface() {
        
    }
    
    func bindWithViewModel() {
        
    }
}
