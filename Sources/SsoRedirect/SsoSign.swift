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

public protocol SsoSignDelegate {
    func onUserInfoReceived(onUserInfoReceivedMessage: String)
}

public class SsoSign: UIViewController {
    var authSession: ASWebAuthenticationSession?
    let cookiename = "expiry-fix-test"
    
    var delegate: SsoSignDelegate? = nil
    
    var contextProvider: AuthContextProvider?
    
    var codeVerifier: String?
    var codeChallenge: String?
    
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
    
    public func initialize(delegateClass: SsoSignDelegate) {
        
        self.delegate = delegateClass
        
        codeVerifier = PKCE.generateCodeVerifier()
        codeChallenge = PKCE.generateCodeChallenge(from: codeVerifier!)
        
        print("CODE VERiFIer: \(codeVerifier!)")
    }
    
    public func login() {
        print("CODE Challenge: \(codeChallenge!)")
        //Initialize auth session
        let callbackUrl = "sampleproj://sample.com?"
        let callbackURI = callbackUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        self.authSession = ASWebAuthenticationSession(url: URL(string: "https://dev-passport.rctiplus.com/login?application_id=5669acac-d4a1-4f5e-87ca-0d989df5efa7&redirect_uri=sampleproj://sample.com&scope=openid%20profile%20email&code_challenge=\(codeChallenge!)&code_challenge_method=S256&response_type=code&state=1234567890")!, callbackURLScheme: callbackURI, completionHandler: { (callBack:URL?, error:Error? ) in
            guard error == nil, let successURL = callBack else {
                print(error!)
                return
            }
            
            if #available(iOS 13, *) {
                self.contextProvider?.clear() // clear context
            }
            
            let cookievalue = self.getQueryStringParameter(url: (successURL.absoluteString), param: self.cookiename)
            
            print("cookie value: \(String(describing: cookievalue))")
            let auth_code = successURL.absoluteString.slice(from: "authorization_code=", to: "&state")
            print("callback: \(String(describing: auth_code))")
            
            let tokenRequest = TokenModel.Request(application_id: "5669acac-d4a1-4f5e-87ca-0d989df5efa7",
                                                  application_secret: "8e27e7c85ca50e592a6e07e800b46de83e8936704fd34f14b7c3f6847549c929",
                                                  token_type: "bearer",
                                                  authorization_code: auth_code,
                                                  code_verifier: self.codeVerifier)
            
            SsoService.requestWithHeader(method: .post, auth_Key: "UzBZTjVYT0xRVTVuQWxkOkhLeHlLR05BOVYwMHVVaUJUbGY3bFE1djlpd2lFVVhrb01zQWhnaG9GZHF4Sg==", params: tokenRequest.toJSON(), url: "https://dev-auth-api.rctiplus.com/v1/partner/token", completion: { respon, xdata in
                
                do {
                    let decodeData = try JSONDecoder().decode(TokenModel.Response.self, from: xdata)
                    self.getInfo(modelResponse: decodeData)
                }catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            })
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
    
    func getInfo(modelResponse : TokenModel.Response) {
//        print("MODEL RESPONSE: \(modelResponse)")
        let access_token = "Bearer \(modelResponse.access_token!)"
        
        SsoService.requestWithHeader(method: .get, auth_Key: access_token, url: "https://dev-auth-api.rctiplus.com/v1/user/info", completion: { respon, xdata in
            
//            print("DATA RESP INFO: \(String(describing: respon))")
            
        })
        
    }
}
