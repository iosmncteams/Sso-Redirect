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
    public func login() {
        let vc = Browser()
        self.present(vc, animated: true)
    }
}
