//
//  BCFIWebViewController.swift
//  Medicijnkast
//
//  Created by Pieter Stragier on 18/02/17.
//  Copyright © 2017 PWS. All rights reserved.
//

import UIKit
import WebKit

class BCFIWebViewController: UIViewController, WKUIDelegate {
    weak var medicijn: Medicijn?
    var link: String?
    @IBOutlet weak var webView: WKWebView!
    
    /*
    override func loadView() {
        //let webConfiguration = WKWebViewConfiguration()
        //webView = WKWebView(frame: .zero, configuration: webConfiguration)
        //webView.uiDelegate = self
        //view = webView
    }
    */
    
    var webstring:String?="https://www.apple.com"
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        webstring = link
        navigationItem.title = "BCFI: \(medicijn?.mpnm)"
        
        //let webstring = "https://www.apple.com"
        let myURL = URL(string: webstring!)      // ! because medicijn?
        let myRequest = URLRequest(url: myURL!)
        
        webView.load(myRequest)
    }
    
    // MARK: - share button
    func shareTapped() {
        let vc = UIActivityViewController(activityItems: ["Pieter"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    
    @IBAction func BackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
