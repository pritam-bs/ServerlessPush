//
//  SignInViewController.swift
//  ServerlessPush
//
//  Created by Pritam on 28/2/21.
//

import UIKit
import Reusable
import RxSwift

class SignInViewController: BaseViewController, StoryboardSceneBased, ViewType {
    
    typealias ViewModel = SignInViewModel
    var viewModel: ViewModel?
    
    static var sceneStoryboard = UIStoryboard(name: StoryboardScene.Auth.storyboardName, bundle: nil)
    
    func setupUserInterface() {
        
    }
    
    func bindWithViewModel() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
}
