//
//  TokenModel.swift
//  SSORctiSdk
//
//  Created by RCTI Plus on 03/06/22.
//

import Foundation

enum TokenModel {
    struct Request {
        var application_id: String?
        var application_secret: String?
        var token_type: String?
        var authorization_code: String?
        var code_verifier: String?
        
        func toJSON() -> [String: Any] {
            return [
                "application_id" : application_id ?? "",
                "application_secret" : application_secret ?? "",
                "token_type" : token_type ?? "bearer",
                "authorization_code" : authorization_code ?? "",
                "code_verifier" : code_verifier ?? ""
            ]
        }
    }
    
    struct Response: Codable {
        var access_token: String?
        var id_token: String?
        var refresh_token: String?
        var expires_in: Int?
        var token_type: String?
        
        init () {}
    }
}
