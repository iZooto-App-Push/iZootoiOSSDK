//
//  SecondViewController.swift
//  iZootoiOSProject
//
//  Created by Amit on 12/08/21.
//  Copyright © 2021 Amit. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    var window = UIWindow(frame:UIScreen.main.bounds)
    
      override func viewDidLoad() {
        super.viewDidLoad()
      }
    
      override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
      }
    
      @available(iOS 13.0, *)
      @IBAction func backButtonClicked(_ sender: UIButton) {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let yourVC = storyboard.instantiateViewController(identifier: "HomeViewController")
        let navController = UINavigationController(rootViewController: yourVC)
        navController.modalPresentationStyle = .fullScreen
        window!.rootViewController = navController
        window!.makeKeyAndVisible()
      }
    }

