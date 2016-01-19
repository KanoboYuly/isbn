//
//  ViewController.swift
//  IsbnSearch
//
//  Created by Yuly Espinoza on 1/14/16.
//  Copyright © 2016 YE. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var isbnTextfield: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var resultsTextview: UITextView!
    @IBOutlet weak var isbnTitle: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var cover: UIImageView!
    
    @IBAction func cleanButton(sender: AnyObject) {
        self.isbnTextfield.text = ""
        self.resultsTextview.text = ""
        self.titleLabel.text = ""
        self.authorsLabel.text = ""
        self.isbnTitle.text = ""
        cover.image = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        findBook()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
        let range = string.rangeOfCharacterFromSet(whitespaceSet)
        if let _ = range {
            return false
        }
        else {
            return true
        }
    }
    
    func findBook() {
        if (isConnectedToNetwork() == true ){
            print("Internet connection OK")
            if isbnTextfield.text != " "  && isbnTextfield.text != "" {
                let string = isbnTextfield.text
                var stringIsnb = string
                let components = stringIsnb!.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter { !$0.isEmpty }
                stringIsnb = components.joinWithSeparator(" ")
                
                var urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
                urls += stringIsnb!
                print(urls)
                let url = NSURL(string: urls)
                let datos:NSData? = NSData(contentsOfURL: url!)
                let texto = String(data: datos!, encoding: NSUTF8StringEncoding)
                print(texto)
                do {
                    let readJson = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
                    let dictionaryJson = readJson as! NSDictionary
                    if texto! != "{}" {
                        let dictionaryJson1 = dictionaryJson["ISBN:\(stringIsnb!)"] as! NSDictionary
                        
                        let dictionaryJson2 =  dictionaryJson1["title"] as! NSString as String
                        self.isbnTitle.text = dictionaryJson2
                        self.titleLabel.text = "Title"
                    
                        var result = [String]()
                        var names = String()
                        if let getAuthors = dictionaryJson1["authors"] as? [[String: AnyObject]] {
                            for blog in getAuthors {
                                if let name = blog["name"] as? String {
                                    result.append(name)
                                    let space = "\r\n"
                                    names += name + space
                                }
                            }
                        }
                        let countAuthors = dictionaryJson1["authors"] as? NSArray
                        if (countAuthors?.count > 1) {
                            self.authorsLabel.text = "Authors"
                        } else {
                            self.authorsLabel.text = "Author"
                        }
                    
                        self.resultsTextview.text = names
                        self.resultsTextview.editable = false
                    
                        if dictionaryJson1["cover"] != nil {
                            let dictionaryJson3 =  dictionaryJson1["cover"] as! NSDictionary
                            let dictionaryJson4 =  dictionaryJson3["medium"]  as! NSString as String
                            let urlCover = NSURL(string: dictionaryJson4)
                            print(urlCover!)
                        
                            let data:NSData? = NSData(contentsOfURL:urlCover!)
                            if data != nil {
                                cover?.image = UIImage(data:data!)
                            } else {
                                cover?.image =  UIImage(named:"noCover.jpg")
                            }
                        } else {
                            cover?.image =  UIImage(named:"noCover.jpg")
                        }
                    } else {
                    self.isbnTitle.text = "This result is not available"
                    self.resultsTextview.text = ""
                    self.titleLabel.text = ""
                    self.authorsLabel.text = ""
                    cover.image = nil
                    }
                 } catch _ {
                
                }
            } else {
                let alert = UIAlertController(title: "ISBN", message: "ISBN is required!", preferredStyle: UIAlertControllerStyle.Alert)
                // add an action (button)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            print("Internet connection FAILED")
            // create the alert
            let alert = UIAlertController(title: "No network connection", message: "You must be connected to the internet to use this app..", preferredStyle: UIAlertControllerStyle.Alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .Reachable
        let needsConnection = flags == .ConnectionRequired
        
        return isReachable && !needsConnection
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        isbnTextfield.delegate = self
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

