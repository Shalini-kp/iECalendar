//
//  CustomAlertView.swift
//  iECalendar
//
//  Copyright © 2020 Shalini. All rights reserved.
//

import UIKit

// AlertView Controller
class CustomAlertView: UIAlertController {
    
    static let sharedInstance = CustomAlertView()
    
    //check whether alert view is already presented
    func isPresentAlertView(_ view: UIView) -> Bool {
        
        guard !view.subviews.isEmpty else {
            //to avoid multiple alertview
            return true
        }
        
        for subview in view.subviews {
            if subview == UIAlertController() {
                return true
            }
        }
        //view.subviews.filter({ $0 == UIAlertController() }).isEmpty
        return false
    }
    
    //default alert with ok and cancel actions
    func defaultAlert(_ view: UIViewController,_ title: String?,_ message: String?,_ okText: String?,_ okStyle: UIAlertAction.Style,_ cancelText: String?,_ cancelStyle: UIAlertAction.Style, alertStyle preffered: UIAlertController.Style) {
        
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title, message: message, preferredStyle: preffered)
            let okAction = UIAlertAction(title: okText ?? "OK", style: okStyle, handler: nil)
            let cancelAction = UIAlertAction(title: cancelText ?? "Cancel", style: cancelStyle, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            //  alert.view.tintColor = UIColor.iECalendarColor
            view.present(alert, animated: true)
        })
    }
    
    //alert with ok action
    func okAlert(_ view: UIViewController,_ title: String?,_ message: String?,_ okText: String?,_ okStyle: UIAlertAction.Style, alertStyle preffered: UIAlertController.Style) {
        
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title, message: message, preferredStyle: preffered)
            let okAction = UIAlertAction(title: okText ?? "OK", style: okStyle, handler: nil)
            
            alert.addAction(okAction)
            // alert.view.tintColor = UIColor.iECalendarColor
            view.present(alert, animated: true)
        })
    }
    
    //alert for no internet connection
    func noInternetConnection(_ view: UIViewController) {
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            
            // alertController.view.tintColor = UIColor.iECalendarColor
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKAction)
            OperationQueue.main.addOperation {
                view.present(alertController, animated: true, completion:nil)
            }
        })
    }
    
    //alert for location permission
    func locationPermissionAlert(_ view: UIViewController,_ isMandatory: Bool,_ isLocationService: Bool) {
        
        DispatchQueue.main.async(execute: {
            var message = "Turn On Location Services and Allow  Access to ‘iECalendar’  to determine your location. Your location will be used in iECalendar features like chats, marking attendance and sharing live location."
            
            if isLocationService {
                message = "Enable general location services in Settings to continue\n Privacy->Location Services->Enable"
            }
            
            let alertController = UIAlertController(title: "Location Services Disabled", message: message, preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .destructive){ (_) -> Void in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url as URL)
                    }
                }
            }
            alertController.addAction(settingsAction)
            
            if !isMandatory {
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel , handler: nil)
                alertController.addAction(cancelAction)
            }
            
            //alertController.view.tintColor = UIColor.iECalendarColor
            OperationQueue.main.addOperation {
                
                if !self.isPresentAlertView(view.view) {
                    view.present(alertController, animated: true, completion: nil)
                }
            }
        })
    }
    
    //alert for settings
    func alertWithSettings(_ view: UIViewController,_ isMandatory: Bool,_ title: String?,_ message: String?, alertStyle preffered: UIAlertController.Style){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preffered)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .destructive){ (_) -> Void in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url as URL)
                }
            }
        }
        alertController.addAction(settingsAction)
        
        if !isMandatory {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel , handler: nil)
            alertController.addAction(cancelAction)
        }
        
        OperationQueue.main.addOperation {
            if !self.isPresentAlertView(view.view) {
                view.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    //alert with timer
    func timerAlert(_ view: UIViewController,_ title: String?,_ message: String?,_ timer: DispatchTime, alertStyle preffered: UIAlertController.Style) {
        
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title, message: message, preferredStyle: preffered)
            
            //alert.view.tintColor = UIColor.iECalendarColor
            view.present(alert, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: timer){
                alert.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    //declare global alertController
    var alertView = UIAlertController()
    
    //present alertController
    func presentAlertView(_ viewcontroller: UIViewController,_ title: String?,_ message: String?, alertStyle preffered: UIAlertController.Style) {
        DispatchQueue.main.async(execute: {
            self.alertView = UIAlertController(title: title, message: message, preferredStyle: preffered)
            
            self.alertView.view.tintColor = UIColor.black
            viewcontroller.present(self.alertView, animated: true)
        })
    }
    
    //dismiss alertController
    func dissmissAlertView(_ viewcontroller: UIViewController) {
        DispatchQueue.main.async(execute: {
            
            //            for subViews in viewcontroller.view.subviews {
            //                print("UIAlertController subViews =>\(subViews)")
            //                if subViews is UIAlertController {
            //                    self.alertView.dismiss(animated: true, completion: nil)
            //                }
            //            }
            self.alertView.dismiss(animated: true, completion: nil)
        })
    }
}
