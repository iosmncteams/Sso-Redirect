//
//  File.swift
//  
//
//  Created by User on 14/06/22.
//

import AuthenticationServices
import UIKit

public protocol AuthContextProvider where Self: ASWebAuthenticationPresentationContextProviding {

  func clear()
}

final class ContextProvider: NSObject, AuthContextProvider {

  private var context: ASPresentationAnchor?

  // MARK: - ASWebAuthenticationPresentationContextProviding

  public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    let window = UIWindow()
    window.makeKeyAndVisible()
    self.context = window
    return window
  }

  public func clear() {
    context = nil
  }
}

