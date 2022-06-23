//
//  RefreshModel.swift
//  SSORctiSdk
//
//  Created by RCTI Plus on 03/06/22.
//

import Foundation

enum RefreshModel {
    struct Request {
        var application_id: String?
        var application_secret: String?
        var token_type: String?
        var refresh_token: String?
        
        func toJSON() -> [String: Any] {
            return [
                "application_id" : application_id ?? "",
                "application_secret" : application_secret ?? "",
                "token_type" : token_type ?? "bearer",
                "refresh_token" : refresh_token ?? ""
            ]
        }
    }
    
    struct Response: Codable {
        var access_token: String?
        var id_token: String?
        var expires_in: Int?
        var refresh_token: String?
        var token_type: String?
        
        init () {}
    }
}
