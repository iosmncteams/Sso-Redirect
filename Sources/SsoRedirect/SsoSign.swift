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
    func onLogout(onLogoutMessage: String)
}

public class SsoSign: UIViewController {
    var authSession: ASWebAuthenticationSession?
    let cookiename = "expiry-fix-test"
    
    var delegate: SsoSignDelegate? = nil
    
    var contextProvider: AuthContextProvider?
    
    var codeVerifier: String?
    var codeChallenge: String?
    
    var APPLICATION_NAME: String = ""
    var APPLICATION_ID: String = ""
    var APPLICATION_SECRET: String = ""
    var AUTH_URL_SSO: String = ""
    var TOKEN_URL_SSO: String = ""
    var USER_INFO_URL_SSO: String = ""
    var LOGOUT_URL_SSO: String = ""
    var ACCESS_TOKEN: String = ""
    
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
    
    public func initialize(applicationID: String,
                           applicationSecret: String,
                           scope: String,
                           authUrl: String,
                           tokenUrl: String,
                           userInfoUrl: String,
                           logoutUrl: String,
                           delegateClass: SsoSignDelegate) {
        
        self.delegate = delegateClass
        
        let urlString = scope.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        self.APPLICATION_NAME = urlString!
        self.APPLICATION_ID = applicationID
        self.APPLICATION_SECRET = applicationSecret
        self.AUTH_URL_SSO = authUrl
        self.TOKEN_URL_SSO = tokenUrl
        self.USER_INFO_URL_SSO = userInfoUrl
        self.LOGOUT_URL_SSO = logoutUrl
        
        codeVerifier = PKCE.generateCodeVerifier()
        codeChallenge = PKCE.generateCodeChallenge(from: codeVerifier!)
    }
    
    public func login() {
        print("CODE Challenge: \(APPLICATION_NAME)")
        //Initialize auth session
        let callbackUrl = "sampleproj://sample.com?"
        let callbackURI = callbackUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        let baseUrl: String = "\(AUTH_URL_SSO)?application_id=\(APPLICATION_ID)&redirect_uri=sampleproj://sample.com&scope=\(APPLICATION_NAME)&code_challenge=\(codeChallenge!)&code_challenge_method=S256&response_type=code&state=1234567890"
        
        print("BASE_URL: \(baseUrl)")
        
        self.authSession = ASWebAuthenticationSession(url: URL(string: baseUrl)!, callbackURLScheme: callbackURI, completionHandler: { (callBack:URL?, error:Error? ) in
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
            
            let tokenRequest = TokenModel.Request(application_id: self.APPLICATION_ID,
                                                  application_secret: self.APPLICATION_SECRET,
                                                  token_type: "bearer",
                                                  authorization_code: auth_code,
                                                  code_verifier: self.codeVerifier)
            
            SsoService.requestWithHeader(method: .post, auth_Key: "UzBZTjVYT0xRVTVuQWxkOkhLeHlLR05BOVYwMHVVaUJUbGY3bFE1djlpd2lFVVhrb01zQWhnaG9GZHF4Sg==", params: tokenRequest.toJSON(), url: "\(self.TOKEN_URL_SSO)", isGetInfo: false, completion: { respon, xdata, statusCode in
                
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
    }
    
    public func logout() {
        SsoService.requestWithHeader(method: .post, auth_Key: self.ACCESS_TOKEN, url: self.LOGOUT_URL_SSO, isGetInfo: false, completion: { respon, xdata, statusCode in
            if statusCode == 200 {
                self.delegate?.onLogout(onLogoutMessage: "Logout Berhasil")
            }
        })
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func getInfo(modelResponse : TokenModel.Response) {
        self.ACCESS_TOKEN = "Bearer \(modelResponse.access_token!)"
        
        SsoService.requestWithHeader(method: .get, auth_Key: self.ACCESS_TOKEN, url: "\(self.USER_INFO_URL_SSO)", isGetInfo: true, completion: { respon, xdata, statusCode in
            
            let responseData = String(data: xdata, encoding: String.Encoding.utf8)
            self.delegate?.onUserInfoReceived(onUserInfoReceivedMessage: responseData ?? "")
        })
        
    }
}
