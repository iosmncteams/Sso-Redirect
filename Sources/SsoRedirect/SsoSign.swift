//
//  File.swift
//  
//
//  Created by R+IOS on 10/06/22.
//

import Foundation
import UIKit

public class SsoSign: UIViewController {
    
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
    
    public func login() {
        let vc = Browser()
        getTopMostViewController()?.present(vc, animated: true)
    }
}
