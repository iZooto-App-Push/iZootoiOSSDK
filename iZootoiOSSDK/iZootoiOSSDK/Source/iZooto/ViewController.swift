//
//  ViewController.swift
//  iZooto
//
//  Created by Amit on 30/01/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController,WKUIDelegate {
    var window : UIWindow?
     var webView: WKWebView!
    static var seriveURL : String?
    static var title : String?

    
    override func loadView() {
        super.loadView()
              let webConfiguration = WKWebViewConfiguration()
              webView = WKWebView(frame: .zero, configuration: webConfiguration)
              webView.uiDelegate = self
              webView.frame=self.view.bounds
              view.addSubview(webView)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setToolBar()
        webView.scrollView.contentInset = UIEdgeInsets(top: 43,left: 0,bottom: 0,right: 0);
            if let url = URL(string: ViewController.seriveURL!) {
              let request = URLRequest(url: url)
              webView.load(request)
           }
    }
        private func setToolBar() {
        let screenWidth = self.view.bounds.width
        let backButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(backAction))
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        toolBar.isTranslucent = true
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.items = [backButton]
        view.addSubview(toolBar)
        toolBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
      }
    @objc func backAction(){
        dismiss(animated: true, completion: nil)
    }



  
}
