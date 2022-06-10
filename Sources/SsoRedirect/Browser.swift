//
//  File.swift
//  
//
//  Created by R+IOS on 10/06/22.
//

import WebKit
//

class Browser: UIViewController {
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://dev-passport.rctiplus.com/login?application_id=5669acac-d4a1-4f5e-87ca-0d989df5efa7&redirect_uri=sampleproj://sample.com&scope=openid%20profile%20email&code_challenge=gptOwceoBveAK7QbKBcQxb59_aiaLkdtQHabaElaVGo&code_challenge_method=S256&response_type=code&state=1234567890")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}

extension Browser: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        print("@absoluteString =\(url.absoluteString)")
        print("@absoluteURL = \(url.absoluteURL)")
        print("@host = \(url.host ?? "")")
        print("@query = \(url.query ?? "")")
        print("@scheme = \(url.scheme ?? "")")
        print("@type = \(navigationAction.navigationType.rawValue)")
        print("@path = \(url.path)")
        print("@url = \(url)")
    }
}
