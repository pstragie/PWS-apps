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
    
    @IBOutlet weak var webView: WKWebView!
    
    /*
    override func loadView() {
        //let webConfiguration = WKWebViewConfiguration()
        //webView = WKWebView(frame: .zero, configuration: webConfiguration)
        //webView.uiDelegate = self
        //view = webView
    }
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "BCFI: \(medicijn?.mpnm)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        let webstring = medicijn?.link2mpg
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
