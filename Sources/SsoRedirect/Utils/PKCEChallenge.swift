//
//  PKCEChallenge.swift
//  SSORctiSdk
//
//  Created by RCTI Plus on 03/06/22.
//

import AuthenticationServices
import Combine
import CryptoKit

extension Data {
    // Returns a base64 encoded string, replacing reserved characters
    // as per the PKCE spec https://tools.ietf.org/html/rfc7636#section-4.2
    func pkce_base64EncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

enum PKCE {
    static func generateCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return Data(buffer).base64EncodedString()
    }

    static func generateCodeChallenge(from string: String) -> String? {
        guard let data = string.data(using: .utf8) else { return nil }
        if #available(macOS 10.15, *) {
            let hashed = SHA256.hash(data: data)
            return Data(hashed).pkce_base64EncodedString()
        } else {
            // Fallback on earlier versions
            return ""
        }
        
    }
}
