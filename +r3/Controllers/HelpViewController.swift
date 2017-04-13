//
//  HelpViewController.swift
//  +r3
//
//  Created by Xin Hua on 9/23/16.
//  Copyright © 2016 Igor Gubanov. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet var webView: UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load;
        loadWebView()        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBtnBack() {
        self.dismiss(animated: true) {
            
        }
    }

    // MARK: - Load
    func loadWebView() {
        // Load;
        let urlString = "http://r3.rna.webfactional.com/it/382-2/"
        let url = URL(string: urlString)
        let urlRequest = URLRequest(url: url!)
        
        webView?.loadRequest(urlRequest)
    }


}
