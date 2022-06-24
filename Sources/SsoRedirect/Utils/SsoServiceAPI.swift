//
//  SsoServiceAPI.swift
//  SSORctiSdk
//
//  Created by RCTI Plus on 03/06/22.
//

import Foundation

enum SsoService {
    
    static func requestWithHeader(method: Methods, auth_Key: String = "",header: [String: String] = [:] , params: [String: Any] = [:], url: String, isGetInfo: Bool?, completion: @escaping ([String: Any]?, Data, Int) -> Void) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method.rawValue
        
        if !params.isEmpty {
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(auth_Key, forHTTPHeaderField: "Authorization")
        request.allHTTPHeaderFields = header

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            guard let data = data, error == nil else { return }
            if let httpResponse = response as? HTTPURLResponse {
                if isGetInfo! {
                    completion(nil, data, httpResponse.statusCode)
                }else{
                    do {
                        // make sure this JSON is in the format we expect
                        // convert data to json
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            // try to read out a dictionary
                            
                            if let xData = json["data"] as? [String:Any] {
                                
                                let jsonData = try JSONSerialization.data(withJSONObject: xData)
                                DispatchQueue.main.async {
                                    completion(xData, jsonData, httpResponse.statusCode)
                                }
                            }
                        }
                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                }
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
