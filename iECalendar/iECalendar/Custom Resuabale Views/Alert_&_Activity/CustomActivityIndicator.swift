//
//  CustomAlertViewActivityIndicator.swift
//  iECalendar
//

import UIKit

// Activity Indicator
class CustomActivityIndicator: UIActivityIndicatorView {
    
    static var sharedInstance = CustomActivityIndicator()
    lazy var activity = UIActivityIndicatorView()
    
    //present the activity indicator
    func presentActivityIndicator(_ view: UIView,_ style: UIActivityIndicatorView.Style) {
        DispatchQueue.main.async {
            self.activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            self.activity.style = style
            self.activity.color = UIColor.black
            
            self.activity.center = view.center
            view.addSubview(self.activity)
            self.activity.startAnimating()
        }
    }
    
    //check for whether indicator is already presented
    func isPresent(_ view: UIView) -> Bool {
        for subview in view.subviews {
            if subview is UIActivityIndicatorView {
                return true
            }
        }
        return false
    }
    
    //if presented, remove the view
    func removePresentedView(_ view: UIView) {
        for subview in view.subviews {
            if subview is UIActivityIndicatorView {
                subview.removeFromSuperview()
            }
        }
    }
    
    //start animating
    func startAnimating(_ view: UIView) {
        DispatchQueue.main.async {
            self.activity.isHidden = false
            self.activity.startAnimating()
            
            //If the indicator is active, disable user interaction
            view.isUserInteractionEnabled = false
            //            if let leftNavigationItem = viewController.navigationItem.leftBarButtonItems {
            //                for (index, _) in leftNavigationItem.enumerated() {
            //                    viewController.navigationItem.leftBarButtonItems?[index].isEnabled = false
            //                }
            //            }
        }
    }
    
    //stop animating
    func stopAnimating(_ view: UIView) {
        DispatchQueue.main.async {
            self.activity.stopAnimating()
            self.activity.isHidden = true
            
            //If the indicator is inactive, enable user interaction
            view.isUserInteractionEnabled = true
            //            if let leftNavigationItem = viewController.navigationItem.leftBarButtonItems {
            //                for (index, _) in leftNavigationItem.enumerated() {
            //                    viewController.navigationItem.leftBarButtonItems?[index].isEnabled = true
            //                }
            //            }
            
        }
    }
}

/*  ************************ Network time out alert ***************************
 func networkTimeOut(_ viewController: UIViewController) {
 
 DispatchQueue.main.async {
 let window = UIWindow(frame: UIScreen.main.bounds)
 
 //if activity indicator is active, deactive from the screen
 CustomActivityIndicator.sharedInstance.stopAnimating(viewController)
 
 let alertController = UIAlertController(title: "Network Error", message: "Make sure you have proper internet connection and try again!", preferredStyle: .alert)
 
 let settingsAction = UIAlertAction(title: "Settings", style: .default){ (_) -> Void in
 if let url = URL(string: UIApplication.openSettingsURLString) {
 if #available(iOS 10, *) {
 UIApplication.shared.open(url, options: [:], completionHandler: nil)
 } else {
 UIApplication.shared.openURL(url as URL)
 }
 }
 }
 let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
 
 alertController.addAction(settingsAction)
 alertController.addAction(cancelAction)
 alertController.view.tintColor = UIColor(netHex: 0x02BACF)
 
 OperationQueue.main.addOperation {
 window.rootViewController = UIViewController()
 window.windowLevel = UIWindow.Level.alert + 1;
 window.makeKeyAndVisible()
 
 //need to check
 //if window.rootViewController?.view.subviews.filter({ $0 == alertController }).isEmpty ?? true {
 window.rootViewController?.present(alertController, animated: true, completion: nil)
 }
 }
 }
 */
