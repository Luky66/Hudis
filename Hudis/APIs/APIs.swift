//
//  SwissDirectoryAPI.swift
//  Hudis
//
//  Created by Lukas Bühler on 20.10.17.
//  Copyright © 2017 Lukas Bühler. All rights reserved.
//
import Foundation

class API
{
    // The basic information for an API
    
    var url = "";
    var key = "";
    var maxRequestSize = 10;

    init(url: String, key: String)
    {
        self.url = url;
        self.key = key;
    }
    
    static func getKeyFromFile(fileName: String) -> String
    {
        let path = Bundle.main.path(forResource: fileName, ofType: "txt")
        
        do {
            let str = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            return str.substring(to: str.index(of:"\n")!) // This is dangerous
        }
        catch
        {
            print("Error while reading key from file");
            return "";
        }
    }
}

class SwissDirectoryAPI: API
{
    // The swiss directories API
    let APIKeyFileName = "SwissAPIKey"
    
    init()
    {
        print(API.getKeyFromFile(fileName: APIKeyFileName));
        super.init(url: "https://tel.search.ch/api/", key: API.getKeyFromFile(fileName: APIKeyFileName))
    }
    
    static func getRequestUrl(api: API, phoneNumber: String, pos: Int) -> String?
    {
        phoneNumber.replacingOccurrences(of: " ", with: "+", options: NSString.CompareOptions.literal, range:nil)
        let urlParameters = "?tel=\(phoneNumber)&maxnum=\(api.maxRequestSize)&pos=\(pos)&key=\(api.key)";
        
        return String("\(api.url)\(urlParameters)");
        
    }
    
}
