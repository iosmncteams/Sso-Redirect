//
//  File.swift
//  
//
//  Created by R+IOS on 10/06/22.
//

import Foundation
import UIKit
import SafariServices
import AuthenticationServices

public class SsoSign: UIViewController {
    var authSession: ASWebAuthenticationSession?
    let cookiename = "expiry-fix-test"
    
    var contextProvider: AuthContextProvider?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getTopMostViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first

        return keyWindow?.rootViewController
    }
    
    public func login() {
//        let vc = Browser()
//        getTopMostViewController()?.present(vc, animated: true)
        //Initialize auth session
        let callbackUrl = "sampleproj://sample.com?"
        let callbackURI = callbackUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        self.authSession = ASWebAuthenticationSession(url: URL(string: "https://dev-passport.rctiplus.com/login?application_id=5669acac-d4a1-4f5e-87ca-0d989df5efa7&redirect_uri=sampleproj://sample.com&scope=openid%20profile%20email&code_challenge=gptOwceoBveAK7QbKBcQxb59_aiaLkdtQHabaElaVGo&code_challenge_method=S256&response_type=code&state=1234567890")!, callbackURLScheme: callbackURI, completionHandler: { (callBack:URL?, error:Error? ) in
            guard error == nil, let successURL = callBack else {
                print(error!)
                return
            }
            
            if #available(iOS 13, *) {
                self.contextProvider?.clear() // clear context
            }
            
            let cookievalue = self.getQueryStringParameter(url: (successURL.absoluteString), param: self.cookiename)
            
            print("cookie value: \(cookievalue)")
            print("callback: \(successURL)")
        })
        
        if #available(iOS 13, *) {
            self.contextProvider = ContextProvider() // retain context
            self.authSession?.presentationContextProvider = self.contextProvider
        }
        
        self.authSession?.start()
        
        print("mulai start session")
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}
