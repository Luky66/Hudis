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
    
    func getMainPhoneNumberForDisplay() -> String
    {
        return PhoneNumbers.getReadableStringFromInt(int: self.phone)
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
    
    func setAddressFromSomething(holderInfo: [String: String])
    {
        let street = holderInfo["tel:street"]
        let streetno = holderInfo["tel:streetno"]
        let zip = holderInfo["tel:zip"]
        let city = holderInfo["tel:city"]
        let canton = holderInfo["tel:canton"]
        let country = holderInfo["tel:country"]
        
        // Address
        if
            street != nil &&
            streetno != nil &&
            zip != nil &&
            city != nil
        {
            // We have all the address info, let's set it.
            
            self.address = """
                \(street!) \(streetno!)
                \(zip!) \(city!)
            """
            
            if(canton != nil)
            {
                 self.address = " \(canton!)"
            }
            
            if(country != nil)
            {
                self.address += "\n \(country!)"
            }
            
        }
    }
}

class CompanyHolder: Holder
{
    var category = "";
    
    init()
    {
        super.init(caller: Caller())
    }
}

class PrivateHolder: Holder
{
    var firstName = "";
    var maidenName = "";
    
    init()
    {
        super.init(caller: Caller())
    }
    
    override func getDisplayName() -> String {
        
        if(self.maidenName != "")
        {
            // If there is a maiden name
            return "\(firstName) \(name) - \(maidenName)"
        }
        else
        {
            // There is no maiden name
            return "\(firstName) \(name)"
        }
    }
}
