//
//  PhoneNumbers.swift
//  Hudis
//
//  Created by Lukas Bühler on 20.10.17.
//  Copyright © 2017 Lukas Bühler. All rights reserved.
//

import Foundation

class PhoneNumbers {
    
    // Here's the definition for the two string types mentioned here
    // Compact string example: "+41791234567"
    // Readable string example: "079 123 45 67"
    // Int (UInt64) example: 41791234567 (41_79_123_45_67)
    
    // TODO: 117, 144, 118, 1414, 1818 and co.
    // Also nice to have different nice strings like: 0800 800 800 instead of 080 080 08 00
    
    
    // Compact string -> Int
    static func getIntFromCompactString(string: String) -> UInt64
    {
        // Format
        var str = string.removeWhitespaces()
        str = str.replacingOccurrences(of: "+", with: "", options: NSString.CompareOptions.literal, range:nil) // Removes the plus
        
        // Convert
        return UInt64(str)!;
    }
    
    // Int -> Compact string
    static func getCompactStringFromInt(int: UInt64) -> String
    {
        return "+\(String(int))";
    }
    
    // Int -> Readable string
    static func getReadableStringFromInt(int: UInt64) -> String
    {
        var str = String(int); // 41791234567
        if(str.count == 11)
        {
            str = "0\(str[2...3]!) \(str[4...6]!) \(str[7...8]!) \(str[9...10]!)"
            
            return str; // 079 123 45 67
        }
        else
        {
            print("Couldn't convert the number..., you'll get the compact instead")
            return PhoneNumbers.getCompactStringFromInt(int: int)
        }
    }
}
