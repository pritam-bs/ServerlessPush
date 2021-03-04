//
//  BaseViewController.swift
//  ServerlessPush
//
//  Created by Pritam on 1/3/21.
//

import UIKit
import NVActivityIndicatorView
import RxSwift

class BaseViewController: UIViewController, ActivityIndicatorViewType, ErrorSupportViewType {
    func shouldShowErrorDialog(errorResponse: AppError, requestTag: String) -> Bool {
        return true
    }
    
    func showErrorAlert(appError: AppError, action: @escaping (ErrorAlertActionType) -> Void) {
        if appError == .sessionExpired {
            self.showSessionExpiredAlert(action: action)
        }
    }
    
    func showSessionExpiredAlert(action: @escaping (ErrorAlertActionType) -> Void) {
        let title = L10n.Error.sessionExpiredTitle
        let message = L10n.Error.sessionExpiredMessage
        let alertAction = UIAlertAction(
            title: L10n.Alert.sessionExpiredActionTitle,
            style: .default) { (_) in
            action(ErrorAlertActionType.logout)
        }
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    var activityIndicatorView: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origin = CGPoint(
            x: self.view.center.x - ActivityIndicatorProperties.size.width/2,
            y: self.view.center.y - ActivityIndicatorProperties.size.height/2)
        let size = ActivityIndicatorProperties.size
        let frame = CGRect(origin: origin, size: size)
        
        let type = ActivityIndicatorProperties.type
        let color = ActivityIndicatorProperties.color
        self.activityIndicatorView = NVActivityIndicatorView(
            frame: frame,
            type: type,
            color: color,
            padding: 0.0)
        if let activityIndicatorView = activityIndicatorView {
            self.view.addSubview(activityIndicatorView)
        }
    }
    
    func startActivityIndicator() {
        activityIndicatorView?.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicatorView?.stopAnimating()
    }
}
