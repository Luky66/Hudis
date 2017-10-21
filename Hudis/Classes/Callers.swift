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
    
    // Vars
    var name = ""; // The name of the phone number owner
    var phone: UInt64; // 41_00_000_00_00
    var isBlocked = false;
    
    // Constructors
    init()
    {
        self.phone = 41_00_000_00_00 as UInt64; // Needs to be handled this way to work on 32-bit devices
    }
    
    init(phone: UInt64) {
        self.phone = phone;
    }
    
    init(holder: Holder)
    {
        self.name = holder.name;
        self.phone = holder.phone;
        self.isBlocked = holder.isBlocked;
    }
    
    func toHolder() -> Holder
    {
        return self as! Holder;
    }
    
    func getDisplayName() -> String
    {
        return name;
    }
    
    func getDisplayPhoneNumber() -> String
    {
        return PhoneNumbers.getPhoneNumberStringFromInt(int: self.phone)
    }
}

class Holder: Caller {
    
    // This class includes all the bit the user would like to see in the app when we can make a request to the servers and give him more.
    // This data is not stored and only used at runtime to go easy on the storage
    
    // Vars
    
    var address = "";
    var detailsLink = "";
    var copyright = "";
    
    var emails = [String]()
    var extraPhones = [UInt64]()
    
    // Constructors
    
    init(caller: Caller)
    {
        super.init(phone: caller.phone);
        
        self.name = caller.name;
        self.isBlocked = caller.isBlocked;
    }
    
    // Functions
    func requestAdditonalInformation()
    {
        
    }
    
    
    func toCaller() -> Caller
    {
        return self as Caller;
    }
}

class CompanyHolder: Holder
{
    var category = "";
    
}

class PrivateHolder: Holder
{
    var firstName = "";
    var maidenName = "";
    
    override func getDisplayName() -> String {
        if(self.maidenName != "")
        {
            return "\(firstName) \(name)-\(maidenName)"
        }
        else
        {
            return "\(firstName) \(name)"
        }
        
    }
}
