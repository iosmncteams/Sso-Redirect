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
    func onAccessTokenReceived(onAccessTokenReceivedMessage: String)
    func onTokenExpiredTimeReceived(onTokenExpiredTimeReceivedMessage: String)
    func onRefreshTokenReceived(onRefreshTokenReceivedMessage: String)
    func onIdTokenReceived(onIdTokenReceivedMessage: String)
    func onUserIdReceived(onUserIdReceivedMessage: String)
    func onAuthorized(onAuthorizedMessage: String)
    func onUserInfoReceived(onUserInfoReceivedMessage: String)
    func onLogout(onLogoutMessage: String)
}

public class SsoSign: UIViewController, ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        return window ?? ASPresentationAnchor()
    }
    
    var authSession: ASWebAuthenticationSession?
//    let cookiename = "expiry-fix-test"
    
    var delegate: SsoSignDelegate? = nil
    
    var contextProvider: AuthContextProvider?
    var tokenModel = TokenModel.Response()
    var userData: String = ""
    
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
    var CALLBACK_URL: String = ""
    var SUFFIX_URL: String = "://oauth2redirect"//"://ssoredirectclient"
    var AUTH_KEY: String = "UzBZTjVYT0xRVTVuQWxkOkhLeHlLR05BOVYwMHVVaUJUbGY3bFE1djlpd2lFVVhrb01zQWhnaG9GZHF4Sg=="
    
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
                           bundleId: String,
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
        self.CALLBACK_URL = bundleId + self.SUFFIX_URL
        
        codeVerifier = PKCE.generateCodeVerifier()
        codeChallenge = PKCE.generateCodeChallenge(from: codeVerifier!)
    }
    
    public func login() {
        
        //Initialize auth session
//        let callbackUrl = "com.mncgroup.sampleproject2://ssoredirectclient?"
        let callbackURI = "\(CALLBACK_URL)?".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        let baseUrl: String = "\(AUTH_URL_SSO)?application_id=\(APPLICATION_ID)&redirect_uri=\(self.CALLBACK_URL)&scope=\(APPLICATION_NAME)&code_challenge=\(codeChallenge!)&code_challenge_method=S256&response_type=code&state=1234567890"
        
        self.authSession = ASWebAuthenticationSession(
            url: URL(string: baseUrl)!,
            callbackURLScheme: callbackURI,
            completionHandler: { (callBack:URL?, error:Error? ) in
            guard error == nil, let successURL = callBack else {
                return
            }
            
            if #available(iOS 13, *) {
                self.contextProvider?.clear() // clear context
            }
            
//            let cookievalue = Utils.getQueryStringParameter(url: (successURL.absoluteString), param: self.cookiename)
            let auth_code = successURL.absoluteString.slice(from: "authorization_code=", to: "&state")
            
            let tokenRequest = TokenModel.Request(application_id: self.APPLICATION_ID,
                                                  application_secret: self.APPLICATION_SECRET,
                                                  token_type: "bearer",
                                                  authorization_code: auth_code,
                                                  code_verifier: self.codeVerifier)
            
            SsoService.requestWithHeader(method: .post, auth_Key: self.AUTH_KEY, params: tokenRequest.toJSON(), url: "\(self.TOKEN_URL_SSO)", isGetInfo: false, completion: { respon, xdata, statusCode in
                
                do {
                    self.tokenModel = try JSONDecoder().decode(TokenModel.Response.self, from: xdata)
                    
                    self.getInfo(modelResponse: self.tokenModel)
                    self.delegate?.onAccessTokenReceived(onAccessTokenReceivedMessage: self.tokenModel.access_token!)
                    self.delegate?.onTokenExpiredTimeReceived(onTokenExpiredTimeReceivedMessage: "\(Utils.intToDate(expiresIn: self.tokenModel.expires_in!))")
                    self.delegate?.onRefreshTokenReceived(onRefreshTokenReceivedMessage: self.tokenModel.refresh_token!)
                    self.delegate?.onIdTokenReceived(onIdTokenReceivedMessage: self.tokenModel.id_token!)
                    self.delegate?.onAuthorized(onAuthorizedMessage: "Authorized Success")
                }catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            })
        })
        
        if #available(iOS 13, *) {
//            self.contextProvider = ContextProvider() // retain context
            self.authSession?.presentationContextProvider = self
            self.authSession?.prefersEphemeralWebBrowserSession = false
        }
        
        if !self.authSession!.start() {
          print("Failed to start ASWebAuthenticationSession")
        }
    }
    
    public func logout() {
        SsoService.requestWithHeader(method: .post, auth_Key: self.ACCESS_TOKEN, url: self.LOGOUT_URL_SSO, isGetInfo: false, completion: { respon, xdata, statusCode in
            if statusCode == 200 {
                self.delegate?.onLogout(onLogoutMessage: "LOGOUT")
            }
        })
    }
    
    public func externalURLScheme() -> String {
        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
              let urlTypeDictionary = urlTypes.first as? [String: AnyObject],
              let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [AnyObject],
              let externalURLScheme = urlSchemes.first as? String else { return "" }
        
        return externalURLScheme
    }
    
    public func getURLSchema() -> String {
        guard let schemas = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String:Any]],
              let schema = schemas.first,
              let urlschema = schema["CFBundleURLName"] as? String
        else { return "" }
        
        return urlschema
    }
    
    public func getBundleIdentifier() -> String {
        return Utils.getBundleIdentifier() ?? ""
    }
    
    public func getAccessToken() -> String {
        return tokenModel.access_token ?? ""
    }
    
    public func getIdToken() -> String {
        return tokenModel.id_token ?? ""
    }
    
    public func getUserInfo() -> String {
        return self.userData
    }
    
    public func refreshTokenAccess() {
        self.refreshToken()
    }
    
    func getInfo(modelResponse : TokenModel.Response) {
        self.ACCESS_TOKEN = "Bearer \(modelResponse.access_token!)"
        
        SsoService.requestWithHeader(method: .get, auth_Key: self.ACCESS_TOKEN, url: "\(self.USER_INFO_URL_SSO)", isGetInfo: true, completion: { respon, xdata, statusCode in
            print("STATUS CODE: \(statusCode)")
            self.userData = String(data: xdata, encoding: String.Encoding.utf8)!
            self.delegate?.onUserInfoReceived(onUserInfoReceivedMessage: self.userData )
        })
        
    }
    
    func refreshToken() {
        let refreshRequest = RefreshModel.Request(application_id: self.APPLICATION_ID,
                                                  application_secret: self.APPLICATION_SECRET,
                                                  token_type: "bearer",
                                                  refresh_token: self.tokenModel.refresh_token)
        
        print("REFRESH REQ: \(refreshRequest.toJSON())")
        
        SsoService.requestWithHeader(method: .post, auth_Key: self.AUTH_KEY, params: refreshRequest.toJSON(), url: "https://rc-game.rctiplus.com/api/auth/token/refresh", isGetInfo: false, completion: { respon, xdata, statusCode in
            
            print("JSON xDATA: \(xdata)")
            
            do {
                self.tokenModel = try JSONDecoder().decode(TokenModel.Response.self, from: xdata)
                print("REFRESH MODEL : \(self.tokenModel)")
                /*self.delegate?.onAccessTokenReceived(onAccessTokenReceivedMessage: self.tokenModel.access_token!)
                self.delegate?.onTokenExpiredTimeReceived(onTokenExpiredTimeReceivedMessage: "\(Utils.intToDate(expiresIn: self.tokenModel.expires_in!))")
                self.delegate?.onRefreshTokenReceived(onRefreshTokenReceivedMessage: self.tokenModel.refresh_token!)
                self.delegate?.onIdTokenReceived(onIdTokenReceivedMessage: self.tokenModel.id_token!)
                self.delegate?.onAuthorized(onAuthorizedMessage: "Authorized Success")*/
            }catch let error as NSError {
                print("Failed to load refresh: \(error.localizedDescription)")
            }
        })
    }
}
