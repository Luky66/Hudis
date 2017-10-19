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
    @IBOutlet weak var callerText: UILabel!
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    
    // UI vars
    var callerRecievedText = "Results:";
    var callerLoadingText = "Loading...";
    var callerErrorText = "Error:";
    
    var phoneNumber = "";
    
    // For XML parsing
    var callers = [Caller]();
    var caller = Caller();
    var foundCharacters = "";
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textField.delegate = self
        self.inputErrorText.text = "";
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Presses return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return (true)
    }

    @IBAction func searchButtonPressed() {
        
        // Phone number we are searching
        
        var tempNumber = textField.text!
        tempNumber = tempNumber.removeWhitespaces();
        tempNumber = tempNumber.replacingOccurrences(of: "\\_", with: "", options: NSString.CompareOptions.literal, range:nil)
        tempNumber = tempNumber.replacingOccurrences(of: "\\-", with: "", options: NSString.CompareOptions.literal, range:nil)
        self.phoneNumber = String(tempNumber);
        
        print(self.phoneNumber.replacingOccurrences(of: "\\d", with: "", options: NSString.CompareOptions.regularExpression, range:nil));
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
        
        
        self.callers.removeAll();
        
        // UI
        self.view.endEditing(true);
        self.loadingWheel.startAnimating();
        self.callerText.text = self.callerLoadingText;
        
        
        let url = URL(string: "https://tel.search.ch/api/?tel=\(self.phoneNumber)") // tel isn't even in the api but it works anyway
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("Error response from API")
                
                // UI
                DispatchQueue.main.async {
                    self.loadingWheel.stopAnimating();
                }
            }else{
                let parser = XMLParser(data: data!)
                parser.delegate = self
                if parser.parse() {
                    // Success, we could parse everything
                    
                    if(self.callers.count > 0)
                    {
                        DispatchQueue.main.async { // This is needed because we can't update the UI outside of the main thread.
                            self.loadingWheel.stopAnimating();
                            self.callerText.text = self.callerRecievedText;
                        }
                    }
                    else
                    {
                        print("No caller found for \(self.phoneNumber)")
                        DispatchQueue.main.async {
                            self.loadingWheel.stopAnimating();
                            self.callerText.text = self.callerErrorText;
                        }
                    }
                    
                }
            }
        }).resume()
    }
    
    // Creates the text for the result
    func makeCallerText(caller: Caller) -> String
    {
        let text = "\(caller.label)\n\(caller.phone)";
        
        return text;
    }
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.foundCharacters += string;
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "title" {
            self.caller.label = self.foundCharacters;
        }
        
        if elementName == "content" {
            
            // Find phone number
            self.caller.phone = Int(findPhoneNumber(string: self.foundCharacters).trimmingCharacters(in: .whitespaces))!;
            
            
        }
        
        if elementName == "entry" {
            let tempCaller = Caller();
            tempCaller.label = self.caller.label.trimmingCharacters(in: .whitespaces);
            tempCaller.phone = self.caller.phone;
            self.callers.append(tempCaller);
            self.caller = Caller();
        }
        
        
        self.foundCharacters = ""
    }
    
    
    func parserDidEndDocument(_ parser: XMLParser) {
        // Maybe do something, but I handle it on the main thread
    }
    
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    
    func findPhoneNumber(string: String) -> String {
        let numbers = matches(for: "^(\\s*(\\+41|0041|0)[\\s\\-\\_]*(\\d{2})[\\s\\-\\_]*(\\d{3})[\\s\\-\\_]*(\\d{2})[\\s\\-\\_]*(\\d{2})\\s*)$|^(\\s*1\\d{2,3}\\s*)$", in: string);
        if(numbers.count > 0)
        {
            return numbers[0];
        }
        else
        {
            return "";
        }
    }
    
    
}

extension String {
    func removeWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
