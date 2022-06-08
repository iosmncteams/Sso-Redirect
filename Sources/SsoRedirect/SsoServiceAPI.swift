//
//  SsoServiceAPI.swift
//  SSORctiSdk
//
//  Created by RCTI Plus on 03/06/22.
//

import Foundation

enum SsoService {
    
    static func requestWithHeader(method: Methods, header: [String: String] = [:] , params: [String: Any] = [:], url: String, completion: @escaping (Data?) -> Void) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method.rawValue
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("UzBZTjVYT0xRVTVuQWxkOkhLeHlLR05BOVYwMHVVaUJUbGY3bFE1djlpd2lFVVhrb01zQWhnaG9GZHF4Sg==", forHTTPHeaderField: "Authorization")
        request.allHTTPHeaderFields = header

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            print("DATA: \(data)")
            print("RESPONSE: \(response)")
            print("ERROR: \(error)")
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            DispatchQueue.main.async {
                completion(data)
            }
        })

        task.resume()
    }
}

enum Methods: String {
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
}
