//
//  File.swift
//  
//
//  Created by User on 17/06/22.
//

import Foundation

enum Utils {
    static func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    static func getBundleIdentifier() -> String? {
        return Bundle.main.bundleIdentifier?.lowercased()
    }
    
    static func intToDate(expiresIn: Int) -> Date {
      let timeInterval = TimeInterval(expiresIn)
      // create NSDate from Double (NSTimeInterval)
      let myNSDate = Date(timeIntervalSince1970: timeInterval)
      return myNSDate
    }
}
