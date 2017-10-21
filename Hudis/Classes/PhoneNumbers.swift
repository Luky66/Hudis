//
//  PhoneNumbers.swift
//  Hudis
//
//  Created by Lukas Bühler on 20.10.17.
//  Copyright © 2017 Lukas Bühler. All rights reserved.
//

import Foundation

class PhoneNumbers {
    
    static func getPhoneNumberStringFromContextString(string: String) -> String {
        let str =  string.substring(from: string.index(string.index(of: "/")!, offsetBy: 4))
        
        return str;
    }
    
    static func getPhoneNumberIntFromString(string: String) -> UInt64 {
        // This is not working for stuff like 117, 1818 and so on
        
        // Format string
        var str = string.removeWhitespaces()
        str = str.substring(from: string.index(string.startIndex, offsetBy: 1))
        
        print(str);
        
        // Convert to UInt64
        return UInt64(str)!;
    }
    
    static func getPhoneNumberStringFromInt(int: UInt64) -> String {
        return String(int); // Not good enough but works for now.
    }
    
}
