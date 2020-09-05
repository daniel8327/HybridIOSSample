//
//  ViewController.swift
//  HybridAppTest
//
//  Created by 장태현 on 2020/09/05.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate,  WKScriptMessageHandler {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .red
        
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        
        // native -> js call (문서 시작시에만 가능한, 환경설정으로 사용함), source부분에 함수 대신 HTML직접 삽입 가능
        let userScript = WKUserScript(source: "redHeader()", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
        
        // js -> native call : name의 값을 지정하여, js에서 webkit.messageHandlers.NAME.postMessage("");와 연동되는 것, userContentController함수에서 처리한다
        contentController.add(self, name: "callNativeNoParams")
        contentController.add(self, name: "callNativeWithParam")
        contentController.add(self, name: "callNativeWithParams")
        
        config.userContentController = contentController
        
        let webView = WKWebView(frame: CGRect(x: 10, y: 10, width: self.view.frame.width - 20, height: self.view.frame.height - 20), configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        //webView.load(URLRequest(url: URL(string: "localhost:3000")!))
        
        
        let url = URL(string: "http://localhost:3000")
        let request = URLRequest(url: url!)
        webView.load(request)
        self.view.addSubview(webView)
        
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    @available(iOS 8.0, *)
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Swift.Void){
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let otherAction = UIAlertAction(title: "확인", style: .default, handler: {action in completionHandler()})
        alert.addAction(otherAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - webView: <#webView description#>
    ///   - navigation: <#navigation description#>
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        /* 아래 잘됨
        webView.evaluateJavaScript("callFromPhone()", completionHandler: {(result, error) in
            if let result = result {
                print(result)
            }
        })
        webView.evaluateJavaScript("callFromPhone()", completionHandler: {
            (any, err) -> Void in
            print(err ?? "no error")
        })
        
        webView.evaluateJavaScript("callFromPhoneWithParam('\(123)')", completionHandler: {
            (any, err) -> Void in
            print(err ?? "no error")
        })
        
        webView.evaluateJavaScript("callFromPhoneWithParams('\(123)', '\(456)')", completionHandler: {
            (any, err) -> Void in 
            print(err ?? "no error")
        })
        
        webView.evaluateJavaScript("aaa()", completionHandler: {
            (any, err) -> Void in
            print(err ?? "no error")
        })*/
    }
    
    // JS -> Native CALL
    @available(iOS 8.0, *)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        print("message.name: \(message.name)")
        if(message.name == "callNativeNoParam"){
            print(message.body)
        } else if message.name == "callNativeWithParam" {
            print(message.body)
            
            let value = message.body as! Int
            print("value \(value)")
        }
        else if message.name == "callNativeWithParams" {
            print(message.body)
            
            let values:[String:String] = message.body as! Dictionary
            print("\(values["subject"]) / \(values["url"])")
        }
    }
}

