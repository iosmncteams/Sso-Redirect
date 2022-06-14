//
//  SsoServiceAPI.swift
//  SSORctiSdk
//
//  Created by RCTI Plus on 03/06/22.
//

import Foundation

enum SsoService {
    
    static func requestWithHeader(method: Methods, auth_Key: String = "",header: [String: String] = [:] , params: [String: Any] = [:], url: String, completion: @escaping ([String: Any]?, Data) -> Void) {
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
            
            do {
                // make sure this JSON is in the format we expect
                // convert data to json
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // try to read out a dictionary
                    if let xData = json["data"] as? [String:Any] {
                        let jsonData = try JSONSerialization.data(withJSONObject: xData)
                        DispatchQueue.main.async {
                            completion(xData, jsonData)
                        }
                        /*if let prices = data["prices"] as? [[String:Any]] {
                         print(prices)
                         let dict = prices[0]
                         print(dict)
                         if let price = dict["price"] as? String{
                         print(price)
                         }
                         }*/
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
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
