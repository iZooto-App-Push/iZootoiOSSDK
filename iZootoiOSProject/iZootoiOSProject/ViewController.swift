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
        print("Recevied","Notifcation")
    }
    
    func onNotificationView(isView: Bool) {
        print("Clicks")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iZooto.delegate = self

    }

}

