//
//  String+Extensions.swift
//  NearBy
//
//  Created by 危末狂龍 on 2023/2/6.
//

import Foundation

extension String {
    
    var formatPhoneForCall: String {
        self.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
    }
    
}
