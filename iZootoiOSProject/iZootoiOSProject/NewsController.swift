//
//  NewsController.swift
//  iZootoiOSProject
//
//  Created by Amit on 12/10/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import Foundation
import WebKit
class NewsController : ViewController
{
  
    @IBOutlet var webviewData: WKWebView!
    
    
   
    override func viewDidLoad() {
           super.viewDidLoad()
        
        let url = URL(string: "https://www.aajtak.com")!
        webviewData.load(URLRequest(url: url))
       }

}
