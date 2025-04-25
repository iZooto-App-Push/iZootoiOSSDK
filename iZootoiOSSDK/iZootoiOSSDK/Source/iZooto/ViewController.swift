//
//  ViewController.swift
//  iZooto
//
//  Created by Amit on 30/01/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class ViewController: UIViewController,WKUIDelegate,WKNavigationDelegate {
    var window : UIWindow?
    var webView: WKWebView?
    static var serviceURL : String?
    static var title : String?
    
    var activityIndicator: UIActivityIndicatorView?
    
    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        webView?.frame=self.view.bounds
        if let safeWebView = webView {
            view.addSubview(safeWebView)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setToolBar()

        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray) // Use the new initializer
        activityIndicator?.center = self.view.center
        activityIndicator?.hidesWhenStopped = true

        if let indicator = activityIndicator {
            view.addSubview(indicator)
        }
        
        webView?.scrollView.contentInset = UIEdgeInsets(top: 43,left: 0,bottom: 0,right: 0);
        if let urlString = ViewController.serviceURL,
            let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView?.load(request)
        } else {
            print("Invalid or missing service URL")
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


    func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator?.startAnimating()
        } else {
            activityIndicator?.stopAnimating()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        showActivityIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        showActivityIndicator(show: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        showActivityIndicator(show: false)
    }
    
}
