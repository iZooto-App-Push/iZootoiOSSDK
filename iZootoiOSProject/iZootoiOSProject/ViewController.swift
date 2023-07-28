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
        //let data = ["language": "bangla"] as [String : Any]
           //iZooto.addUserProperties(data: data)
      //  iZooto.registerForPushNotifications()

    }
    @IBAction func shareToken(_ sender: Any) {
        
        let sharedPref = UserDefaults.standard
        let token = sharedPref.string(forKey: "TOKEN")
        if (token != " " && token != nil)
        {
        let text = "This is a token .\(token!)"
        
            if NSURL(string: "https://apps.apple.com/us/app/idxxxxxxxx?ls=1&mt=8") != nil {
            let objectsToShare = [text]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popup = activityVC.popoverPresentationController {
                    popup.sourceView = self.view
                    popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
                }
            }

            self.present(activityVC, animated: true, completion: nil)
        }
        }
        else{
            print("Token is not found")
        }
      
    }
    @IBAction func clickAction(_ sender: Any) {
        print("clicks")
        
        if #available(iOS 13.0, *) {
            let svc = (storyboard?.instantiateViewController(identifier: "green_vc")) as! SecondViewController
            present(svc, animated: true)

        } else {
            // Fallback on earlier versions
        }
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "newsview") as! NewsController//
//        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    @IBOutlet var webview: WKWebView!
    public static var Webview = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        getNotificationFeedData(isPagination: false) // o index called
        
       
    }
    
    func getNotificationFeedData(isPagination : Bool)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Simulate API call delay
                   iZooto.getNotificationFeed(isPagination: true){ (jsonString, error) in
                       if let error = error {
                           print("\(error.localizedDescription)")
                       } else if let jsonString = jsonString {
                           print("Response = ",jsonString) // response data
                          
                       }
                   }
               }
      
    }
    

}

