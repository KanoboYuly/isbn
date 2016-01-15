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
    
    @IBAction func cleanButton(sender: AnyObject) {
        isbnTextfield.text = ""
        resultsTextview.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        findBook()
    }
    
    func findBook() {
        if (isConnectedToNetwork() == true ){
            print("Internet connection OK")
            if isbnTextfield.text != " "  && isbnTextfield.text != "" {
                let stringIsnb = isbnTextfield.text
                var urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
                urls += stringIsnb!
                print(urls)
                let url = NSURL(string: urls)
                let datos:NSData? = NSData(contentsOfURL: url!)
                let texto = String(data: datos!, encoding: NSUTF8StringEncoding)
                print(texto!)
                resultsTextview.text = texto!
                resultsTextview.editable = false
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

