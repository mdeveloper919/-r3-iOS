//
//  DetailViewController.swift
//  +r3
//
//  Created by Xin Hua on 9/23/16.
//  Copyright © 2016 Igor Gubanov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var webView: UIWebView?
    
    var place: Place! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load;
        loadWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onBtnBack() {
        self.dismiss(animated: true) { 
            
        }
    }
    
    // MARK: - Load
    func loadWebView() {
        // Load;
        webView?.loadHTMLString(place.longInfo!, baseURL: nil)
    }
    

}
