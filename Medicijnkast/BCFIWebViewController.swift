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
    weak var medicijn: MPP?
    var link: String?
    var webView: WKWebView!
    
    @IBOutlet weak var barView: UIView!
    required init(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRect.zero)
        super.init(coder: aDecoder)!
    }
    
    @IBOutlet weak var progressView: UIProgressView!
    
    var webstring:String?="https://www.apple.com"
    override func viewDidLoad() {
        super.viewDidLoad()
        //barView = UIView(frame:CGRect(x:0, y:0, width: view.frame.width, height: 5))
        
        let backButton = UIButton.init(type: .custom)
        backButton.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.frame = CGRect(x:0, y:0, width: 30, height: 40)
        let barBackButton = UIBarButtonItem(customView: backButton)
        
        let forwardButton = UIButton.init(type: .custom)
        forwardButton.setImage(#imageLiteral(resourceName: "forwardButton"), for: .normal)
        forwardButton.addTarget(self, action: #selector(forwardTapped), for: .touchUpInside)
        forwardButton.frame = CGRect(x:0, y:0, width: 30, height: 40)
        let barForwardButton = UIBarButtonItem(customView: forwardButton)
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        navigationItem.rightBarButtonItems = [shareButton, refreshButton, barForwardButton, barBackButton]
        navigationItem.title = "BCFI: \((medicijn?.mp?.mpnm)!)"
        
        view.insertSubview(webView, belowSubview: progressView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: -44)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        webstring = link
        let myURL = URL(string: webstring!)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        webView.addGestureRecognizer(recognizer)
        
        self.view.addSubview(webView)
    }

    func webViewTapped(recognizer: UITapGestureRecognizer) {
        print("Tapped")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "loading") {
        }
        if (keyPath == "estimatedProgress") {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    // MARK: - share button
    func shareTapped() {
        let vc = UIActivityViewController(activityItems: ["Pieter"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    func refreshTapped() {
        webstring = link
        let myURL = URL(string: webstring!)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

    func backTapped() {
        webView.goBack()
    }
    
    func forwardTapped() {
        webView.goForward()
    }
    
    func webView(webView: WKWebView!, didFinishNavigation navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "loading")
    }

    @IBAction func BackButton(_ sender: Any) {
        self.webView.removeObserver(self, forKeyPath: "loading", context: nil)
        self.webView.removeObserver(self, forKeyPath: "estimatedprogress", context: nil)
        dismiss(animated: true, completion: nil)
    }

}
