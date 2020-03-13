//
//  ViewController.swift
//  iZootoiOSProject
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import UIKit
import iZootoiOSSDK

class ViewController: UIViewController,iZootoNotificationActionDelegate {
    func onNotificationReceived(payload: Aps) {
         print("Payload")
    }
    
    func onNotificationView(isView: Bool) {
        print("istap")
    }
    
       
    override func viewDidLoad() {
        super.viewDidLoad()
        iZooto.delegate = self
        let data = ["Number": "3456566", "NAme": "Metro","Amount":"160"]
        iZooto.addEvent(eventName: "Metrocard", data: data)
        iZooto.addUserProperties(data: data)
        

    }

}

