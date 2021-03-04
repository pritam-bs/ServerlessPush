//
//  BaseViewController.swift
//  ServerlessPush
//
//  Created by Pritam on 28/2/21.
//

import UIKit
import Reusable
import RxSwift

class SampleViewController: BaseViewController, StoryboardSceneBased, ViewType {
    typealias ViewModel = SampleViewModel
    var viewModel: SampleViewModel? = SampleViewModel()
    
    static var sceneStoryboard = UIStoryboard(name: StoryboardScene.Sample.storyboardName, bundle: nil)
    
    func setupUserInterface() {
        
    }
    
    func bindWithViewModel() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    @IBAction func showProgressAction(_ sender: Any) {
        viewModel?.showActivityIndicator()
    }
    
    @IBAction func hideProgressAction(_ sender: Any) {
        viewModel?.hideActivityIndicator()
    }
    
    @IBAction func showErrorAction(_ sender: Any) {
        viewModel?.showError()
    }
}
