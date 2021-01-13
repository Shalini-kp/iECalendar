//
//  NetworkTracker.swift
//  iECalendar
//

import Foundation
import UIKit

/// `Internet/No Internet PopUp`
class NetworkTracker: NSObject {
    
    var toastView = UIView()
    var toastLabel = UILabel()
    var isReachable = Bool()
    
    init(_ isReachable: Bool) {
        self.isReachable = isReachable
    }
    
    //MARK: Internet Connection
    func reachabilityChanged() {
        
        if currentViewController != nil {
            
            for i in currentViewController!.view.subviews {
                
                    if i == toastView {
                        i.removeFromSuperview()
                    }
            }
            createToastView(isReachable)
        } else {
            toastView.isHidden = true
        }
        
        print(" reachabilityChanged =>\(isReachable)")
        if isReachable {
            if SessionManager().companyID != "000", let _:[String:String] = UserDefaults.standard.value(forKey: "userInfo") as? [String : String] {
                
                if currentViewController is GalleryCollectionViewController || currentViewController is SurveyMediaPreviewViewController || currentViewController is FormViewController {
                } else {
                    //sync pending survey data
                    let syncSurvey = SurveySync()
                    syncSurvey.syncSurveyBackground()
                }
                
                if isLoggin && !MQTTClass.isConnected {
                    let mqtt = MQTTClass.sharedInstance
                    mqtt.establishConnection(){
                        flag in
                    }
                }
            }
        }
    }
    
    func createToastView(_ isReachable: Bool) {
        var isNavigationBarExists = false
        
        if currentViewController?.navigationController != nil {
            isNavigationBarExists = !((currentViewController?.navigationController!.isNavigationBarHidden) ?? true)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        
        if isNavigationBarExists {
            
            toastView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
            toastLabel = UILabel(frame: CGRect(x: 0, y: 3, width: UIScreen.main.bounds.width, height: 25))
        } else {
            
            toastView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
            toastLabel = UILabel(frame: CGRect(x: 0, y: 34, width: UIScreen.main.bounds.width, height: 25))
        }
        
        toastLabel.font = UIFont(name: "Helvetica-Bold", size: 12)!
        toastLabel.textAlignment = .center;
        var stayby = 2.5
        
        if isReachable {
            toastView.backgroundColor = UIColor(netHex: 0x71BD18)
            toastLabel.textColor = UIColor.white
            toastLabel.text = "Back Online"
        } else {
            toastView.backgroundColor = UIColor.lightGray //(netHex: 0xD0021B)
            toastLabel.textColor = UIColor.white
            toastLabel.text = "No Internet Connection"
            stayby = 4
        }
        
        toastView.addGestureRecognizer(tapGesture)
        toastView.addSubview(toastLabel)
        
        currentViewController!.view.addSubview(toastView)
        
        //hide it after some seconds because of timer in those view controller
        for i in currentViewController!.view.subviews {
            
                if i == toastView {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + stayby){
                        i.removeFromSuperview()
                        self.toastView.isHidden = true
                    }
                }
        }
    }
    
    @objc func handleTapGesture(tapGesture: UITapGestureRecognizer) {
        for i in currentViewController!.view.subviews {
            if i == toastView {
                i.removeFromSuperview()
                toastView.isHidden = true
            }
        }
    }
}
