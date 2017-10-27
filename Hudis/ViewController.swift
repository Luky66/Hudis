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
    @IBOutlet weak var cardPlaceholder: UIView!
    @IBOutlet weak var infoText: UILabel!
    
    
    var phoneNumber = "";
    var cardCenterAtStart = CGPoint();
    var cardSlotWidth = CGFloat(); // The width of a single card slot with margins
    var cards = [CardView]();
    
    // For XML parsing
    var holdersForSearch = [Holder](); // Stores the different types of holders (Private, Company)
    var currentHolderInfo = [String: String]();
    var foundCharacters = "";
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textField.delegate = self
        self.inputErrorText.text = "";
        
        cardCenterAtStart = CGPoint(x: cardPlaceholder.center.x, y: cardPlaceholder.center.y);
        cardSlotWidth = self.cardPlaceholder.bounds.width+self.view.frame.width*0.08
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
    
    
    // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt:12125551212"]];
    
    // ---- Start searching --------------------------

    @IBAction func searchButtonPressed() {
        
        // Phone number we are searching
        if(cards.count > 0)
        {
            self.dismissAllCards();
            self.cards = [CardView]();
        }
        
        
        
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
            
            for i in 0..<holders.count {
                let newCardView = CardView(frame: CGRect(
                    x: vc.cardPlaceholder.frame.origin.x + CGFloat(Double(i)*Double(vc.cardSlotWidth)),
                    y: vc.cardPlaceholder.frame.origin.y,
                    width: vc.cardPlaceholder.bounds.width,
                    height: vc.cardPlaceholder.bounds.height),
                    viewController: vc
                )
                
                newCardView.cardTitleLabel.text = holders[i].getMainPhoneNumberForDisplay()
                newCardView.holderNameLabel.text = holders[i].getDisplayName()
                
                vc.cards.append(newCardView) // Add it to the card array
                vc.cardPlaceholder.addSubview(newCardView);
                
                newCardView.moveToFocusPoint(time: 0.5);
            }
            
        }
    }
    
    
    static func showNoResults(vc: ViewController)
    {
        print("No caller found for \(vc.phoneNumber)")
        DispatchQueue.main.async {
            
            vc.loadingWheel.stopAnimating();
            vc.inputErrorText.text = "No caller found";
            //vc.phoneNumberText.text = "";
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
    
    func dismissAllCards()
    {
        for card in self.cards {
            card.dismiss(time: 0.3)
        }
    }
    
    
    
    // --- Parsing Data (has to be moved eventually) ------------
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.foundCharacters += string;
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        
        if elementName == "entry" {
            // When the entry tag is closed we have collected data in the currentHolderInfo dictionary and perform the necessairy actions to add a holder to the results.
            
            // Go through the arguments and create the holder from the created
            
            // Set the holder
            
            switch self.currentHolderInfo["tel:type"]!
            {
            case "Organisation":
                let newHolder = CompanyHolder();
                
                if self.currentHolderInfo["tel:name"] != nil {
                    // Set the company name
                    newHolder.name = self.currentHolderInfo["tel:name"]!;
                }
                
                if self.currentHolderInfo["tel:phone"] != nil {
                    // Set the phone number
                    newHolder.phone = PhoneNumbers.getIntFromCompactString(string: self.currentHolderInfo["tel:phone"]!)
                }
                
                // Append
                self.holdersForSearch.append(newHolder);
                    
                
            case "Person":
                let newHolder = PrivateHolder();
                
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
                
                if self.currentHolderInfo["tel:phone"] != nil {
                    // Set the phone number
                    newHolder.phone = PhoneNumbers.getIntFromCompactString(string: self.currentHolderInfo["tel:phone"]!)
                }
                
                // Append
                self.holdersForSearch.append(newHolder);
                
            default:
                print("Error unknown type of holder in XML!");
            }
            
            // Reset
            self.foundCharacters = "";
            self.currentHolderInfo = [:]; // Empty the dictionary
        }
        else
        {
            // takt
            let trimmedString = self.foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
            self.currentHolderInfo[elementName] = trimmedString;
            self.foundCharacters = "";
        }
    }
    
    
    
    
    func parserDidEndDocument(_ parser: XMLParser) {
        // Maybe do something, but I handle it on the main thread
    }

    
    // -----------
    
}

extension String {
    func removeWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    subscript (r: CountableClosedRange<Int>) -> String? {
        get {
            guard r.lowerBound >= 0, let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound, limitedBy: self.endIndex),
                let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound, limitedBy: self.endIndex) else { return nil }
            return String(self[startIndex...endIndex])
        }
    }
}
