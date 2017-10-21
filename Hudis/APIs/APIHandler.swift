//
//  ApiHandler.swift
//  Hudis
//
//  Created by Lukas Bühler on 20.10.17.
//  Copyright © 2017 Lukas Bühler. All rights reserved.
//
import Foundation


// I FORGOT THIS SHIT WAS ASYNC

class APIHandler
{
    static var api = SwissDirectoryAPI();
    
    static func callAPI(phone: String, vc: ViewController)
    {
        print("Here m8: "+SwissDirectoryAPI.getRequestUrl(api: api, phoneNumber: phone, pos: 1)!);
        if let url = URL(string: SwissDirectoryAPI.getRequestUrl(api: api, phoneNumber: phone, pos: 1)!)
        {
            URLSession.shared.dataTask(with: url, completionHandler: {
                (data, response, error) in
                
                let status = (response as? HTTPURLResponse)!.statusCode; // Get the status code
                if(status != 200)
                {
                    // Houston we have a problem
                    
                    ViewController.showError(vc: vc, statusCode: status, text: "Non 200 response");
                }
                else
                {
                    // Everything is fine
                    ViewController.parseAndSetData(vc: vc, data: data!);
                }
            }).resume()
        }
        else
        {
            print("The URL couldn't be formed and is therefore nil")
            ViewController.showError(vc: vc, statusCode: 0, text: "Couldn't resolve URL internally.");
            return;
        }
        
    }
}

