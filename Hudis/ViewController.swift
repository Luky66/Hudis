//
//  ViewController.swift
//  Hudis
//
//  Created by Lukas Bühler on 16.10.17.
//  Copyright © 2017 Lukas Bühler. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, XMLParserDelegate {

    // Text field
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var inputErrorText: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
   
    @IBOutlet weak var outerCardView: UIView!
    @IBOutlet weak var innerCardView: UIView!
    @IBOutlet weak var phoneNumberText: UILabel!
    @IBOutlet weak var holderNameText: UILabel!
    @IBOutlet weak var holderAddressText: UILabel!
    
    var phoneNumber = "";
    var cardCenterAtStart = CGPoint();
    
    // For XML parsing
    var holdersForSearch = [Holder]();
    var currentHolderInfo = [String: String]();
    var foundCharacters = "";
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textField.delegate = self
        self.inputErrorText.text = "";
        
        // Shadow for card
        // add the shadow to the base view
        
        outerCardView.clipsToBounds = false
        outerCardView.layer.shadowColor = UIColor.black.cgColor
        outerCardView.layer.shadowOpacity = 1
        outerCardView.layer.shadowOffset = CGSize.zero
        outerCardView.layer.shadowRadius = 15
        outerCardView.layer.shadowPath = UIBezierPath(roundedRect: outerCardView.bounds, cornerRadius: 15).cgPath
        
        innerCardView.clipsToBounds = true
        innerCardView.layer.cornerRadius = 15
        
        cardCenterAtStart = CGPoint(x: outerCardView.center.x, y: outerCardView.center.y);
        setCardHidden(card: self.outerCardView);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // --- Keyboard hiding ---------------------------------------------------
    
    // Hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Presses return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return (true)
    }
    
    
    
    
    // ---- Start searching --------------------------

    @IBAction func searchButtonPressed() {
        
        // Phone number we are searching
        hideCardWithAnimation(card: outerCardView, time: 0.5);
        
        var tempNumber = textField.text!
        tempNumber = tempNumber.removeWhitespaces();
        tempNumber = tempNumber.replacingOccurrences(of: "\\_", with: "", options: NSString.CompareOptions.literal, range:nil)
        tempNumber = tempNumber.replacingOccurrences(of: "\\-", with: "", options: NSString.CompareOptions.literal, range:nil)
        self.phoneNumber = String(tempNumber);
        
        if(self.phoneNumber.replacingOccurrences(of: "\\d", with: "", options: NSString.CompareOptions.regularExpression, range:nil) != "")
        {
            self.inputErrorText.text = "There are some weird symboles in there";
            print("Warning: Unknown symbols in input")
            return;
        }
        else
        {
            self.inputErrorText.text = "";
        }
        print("The phone number is: \(self.phoneNumber)");
        
        self.holdersForSearch.removeAll();
        
        // UI
        self.view.endEditing(true);
        self.loadingWheel.startAnimating();
        
        APIHandler.callAPI(phone: textField.text!, vc: self)
    }
    
    
    
    
    // --- Activating UI Stuff ---------------------------------
    
    static func parseAndSetData(vc: ViewController, data: Data)
    {
        // Start parsing
        
        let parser = XMLParser(data: data)
        parser.delegate = vc;
        
        if parser.parse()
        {
            // Success, we could parse everything
            
            if(vc.holdersForSearch.count > 0)
            {
                makeAndShowCards(vc: vc, holders: vc.holdersForSearch)
            }
            else
            {
                showNoResults(vc: vc)
            }
        }
    }
    
    static func makeAndShowCards(vc: ViewController, holders: [Holder])
    {
        DispatchQueue.main.async { // This is needed because we can't update the UI outside of the main thread.
            vc.loadingWheel.stopAnimating();
            
            // Set the labels
            vc.holderNameText.text = holders[0].getDisplayName();
            vc.phoneNumberText.text = holders[0].getDisplayPhoneNumber();
            
            // Show the cards
            vc.showCardWithAnimation(card: vc.outerCardView, time: 0.5);
        }
    }
    
    
    static func showNoResults(vc: ViewController)
    {
        print("No caller found for \(vc.phoneNumber)")
        DispatchQueue.main.async {
            
            vc.inputErrorText.text = "No caller found";
            vc.phoneNumberText.text = "";
        }
    }
    
    
    static func showError(vc: ViewController, statusCode: Int, text: String)
    {
        DispatchQueue.main.async
        {
            vc.loadingWheel.stopAnimating();
            
            if(statusCode > 0)
            {
                if(round(Double(statusCode/100)) == 4) // If the code starts with the character 4
                {
                    // Error
                    print("Error: \(statusCode)")
                    vc.inputErrorText.text = "Error \(statusCode): \(text)";
                }
                else
                {
                    // No error
                    print("Status: \(statusCode)")
                    vc.inputErrorText.text = "Request returned status code \(statusCode)";
                }
            }
            else
            {
                // Internal error
                print("Internal Error: \(statusCode)")
                vc.inputErrorText.text = "Internal Error: \(text)";
            }
        }
    }
    
    
    
    
    
    // --- Parsing Data (has to be moved eventually) ------------
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.foundCharacters += string;
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        
        
        
        
        if elementName == "entry" {
            // When the entry tag is closed we have collected data in the currentHolderInfo dictionary and perform the necessairy actions to add a holder to the results.
            
            // Go through the arguments and create the holder from the created
            
            // Set the holder type
            var newHolder = Holder(caller: Caller());
            
            switch self.currentHolderInfo["tel:type"]!
            {
                case "Organisation":
                    newHolder = newHolder as! CompanyHolder;
                case "Person":
                    newHolder = newHolder as! PrivateHolder;
                default:
                    print("Error unknown type of holder in XML!");
            }
            
            // Set the caller data
            
            if self.currentHolderInfo["tel:phone"] != nil {
                // Set the phone number
                newHolder.phone = PhoneNumbers.getPhoneNumberIntFromString(string: self.currentHolderInfo["tel:phone"]!)
            }
            
            // Set the holder data
            
            // Address
            if self.currentHolderInfo["tel:street"] != nil {
                // Set the street
                
            }
            if self.currentHolderInfo["tel:streetno"] != nil {
                // Set the street nomber
                
            }
            if self.currentHolderInfo["tel:zip"] != nil {
                // Set the zip
                
            }
            if self.currentHolderInfo["tel:city"] != nil {
                // Set the city
                
            }
            if self.currentHolderInfo["tel:canton"] != nil {
                // Set the canton
                
            }
            if self.currentHolderInfo["tel:country"] != nil {
                // Set the country code
                
            }
            
            
            // Now handle type specific stuff
            
            if newHolder as? CompanyHolder != nil
            {
                // Set company holder data
                let newHolder = newHolder as! CompanyHolder
                
                if self.currentHolderInfo["tel:name"] != nil {
                    // Set the company name
                    newHolder.name = self.currentHolderInfo["tel:name"]!;
                }
            }
            if newHolder as? PrivateHolder != nil
            {
                // Set private holder data
                let newHolder = (newHolder as! PrivateHolder)
                
                if self.currentHolderInfo["tel:firstname"] != nil {
                    // Set the first name
                    newHolder.firstName = self.currentHolderInfo["tel:firstname"]!;
                }
                
                if self.currentHolderInfo["tel:name"] != nil {
                    // Set the surname
                    newHolder.name = self.currentHolderInfo["tel:name"]!
                }
                
                if self.currentHolderInfo["tel:maidenname"] != nil {
                    // Set the maiden name
                    newHolder.maidenName = self.currentHolderInfo["tel:maidenname"]!
                }
            }
            
            // Append the new holder
            self.holdersForSearch.append(newHolder);
            
            // Reset
            self.foundCharacters = "";
            self.currentHolderInfo = [:]; // Empty the dictionary
        }
        else
        {
            // takt
            self.currentHolderInfo[elementName] = self.foundCharacters;
            self.foundCharacters = "";
        }
    }
    
    
    
    
    func parserDidEndDocument(_ parser: XMLParser) {
        // Maybe do something, but I handle it on the main thread
    }
    
    
    
    
    
    
    
    
    
    
    
    // Swiping gestures ----------------------------------
    
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        
        let card = sender.view!
        let point = sender.translation(in: view)
        card.center = CGPoint(x: cardCenterAtStart.x+point.x, y: cardCenterAtStart.y+point.y)
        
        if(sender.state == UIGestureRecognizerState.ended)
        {
            if(card.center.y >= (view.frame.height-275))
            {
                // The card is so far down, just let it go away
                
                // However, calculate the time from the velocity
                let velocityY = sender.velocity(in: view).y;
                var duration = Double(view.frame.height / velocityY);
                if(duration > 0.5)
                {
                    duration = 0.5;
                }
                
                hideCardWithAnimation(card: card, time: duration);
            }
            else
            {
                showCardWithAnimation(card: card, time: 0.3);
            }
        }
        
    }
    
    
    
    func setCardHidden(card: UIView)
    {
        let yOffset = view.frame.height;
        card.center = CGPoint(x: self.cardCenterAtStart.x, y: self.cardCenterAtStart.y+yOffset);
    }
    
    func setCardVisible(card: UIView)
    {
        card.center = self.cardCenterAtStart;
    }
    
    func hideCardWithAnimation(card: UIView, time: Double)
    {
        UIView.animate(withDuration: time) {
            self.setCardHidden(card: card);
        }
    }
    
    func showCardWithAnimation(card: UIView, time: Double)
    {
        UIView.animate(withDuration: time) {
            self.setCardVisible(card: card);
        }
    }
    
    
}

extension String {
    func removeWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
