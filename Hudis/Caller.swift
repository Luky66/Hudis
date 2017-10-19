//
//  Caller.swift
//  Hudis
//
//  Created by Lukas Bühler on 19.10.17.
//  Copyright © 2017 Lukas Bühler. All rights reserved.
//

import Foundation


class Caller {
    
    // This class is nice and compact, optimal for storing a large amount of
    // When going in the app we have this information on the caller and need to create a Holder from this
    
    var name = ""; // The name of the phone number owner
    var phone: UInt64; // 41_00_000_00_00
    var isBlocked = false;
    
    init(phoneNumber: UInt64) {
        self.phone = phoneNumber;
    }
    
}

class Holder: Caller {
    
    // This class includes all the bit the user would like to see in the app when we can make a request to the servers and give him more.
    // This data is not stored and only used at runtime to go easy on the storage
    
    var context = "";
    var detailsLink = "";
    
}
