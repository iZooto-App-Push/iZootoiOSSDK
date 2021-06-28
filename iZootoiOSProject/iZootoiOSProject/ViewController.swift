//
//  ViewController.swift
//  iZootoiOSProject
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import UIKit
import iZootoiOSSDK
import WebKit

class ViewController: UIViewController {
    
   
    
    @IBAction func addProperties(_ sender: Any) {
        let data = ["language": "bangla"] as [String : Any]
            iZooto.addUserProperties(data: data)
      //  iZooto.registerForPushNotifications()

    }
    @IBAction func shareToken(_ sender: Any) {
        
        let sharedPref = UserDefaults.standard
        let token = sharedPref.string(forKey: "Token")
        let text = "This is a token .\(token!)"

        // set up activity view controller
        let textToShare = [text]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]

        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
        
    }
    @IBAction func clickAction(_ sender: Any) {
        print("clicks")
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "newsview") as! NewsController//
//        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    @IBOutlet var webview: WKWebView!
    public static var Webview = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       


      
   

    }

}

