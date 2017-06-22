//
//  ViewController.swift
//  dailyquote
//
//  Created by Manu Rink on 23/10/16.
//  Copyright © 2016 byteroyal. All rights reserved.
//

import UIKit
import Foundation
import MobileCenterAnalytics


enum MyError : Error {
    case HockeyAppTestError
}

class ViewController: UIViewController {
    
    
    @IBOutlet weak var quoteLabel: UILabel!
    
    static let baseURL = "https://myrandomfuncs.azurewebsites.net/api/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGR = UITapGestureRecognizer.init(target: self, action: #selector(ViewController.fetchQuote))
        view.addGestureRecognizer(tapGR)
        
        let swipeGR = UISwipeGestureRecognizer.init(target: self, action: #selector(ViewController.crash))
        swipeGR.direction = .right
        view.addGestureRecognizer(swipeGR)
        
        self.quoteLabel.text = " ... "
        
        fetchQuote()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    static func refreshQuotes () {
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        var task : URLSessionDataTask
        let endpoint = "SeedBingo"
        
        let url = NSURL(string: baseURL + endpoint)
        
        task = defaultSession.dataTask(with: url! as URL) {
            data, response, error in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("SUCCESS: seed of quotes")
                }
            }
        }
        task.resume()
    }
    
    func fetchQuote () {
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        var task : URLSessionDataTask
        let endpoint = "BullshitBingo?maxlength=180"
        
        let url = NSURL(string: ViewController.baseURL + endpoint)
        
        task = defaultSession.dataTask(with: url! as URL) {
            data, response, error in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    
                    DispatchQueue.main.async {
                        do {
                            self.fadeoutLabel()
                            
                            let jsonData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! String
                            let decData = jsonData.data(using: .utf8)
                            let dict = try JSONSerialization.jsonObject(with: decData!) as? Dictionary<String, Any>
                            
                            if let dictionary = dict {
                                
                                if let theStrings = dictionary["strings"] as? [String] {
                                    let quote = theStrings.first
                                    self.quoteLabel.text = "\"\(quote!)\""
                                }
                                
                                self.fadeinLabel()
                            }
                            
                        } catch let error as NSError {
                            print(error)
                        }
                        
                    }
                    print("SUCCESS: fetched quote")
                    
                    MSAnalytics.trackEvent("quoted-fetched-by-user-on-tap")
                }
            }
        }
        task.resume()
    }
    
    private func fadeoutLabel () {
        UIView.animate(withDuration: 1.0) {
            self.quoteLabel.alpha = 0
        }
        
    }
    
    private func fadeinLabel () {
        UIView.animate(withDuration: 0.3) {
            self.quoteLabel.alpha = 1
        }
    }
    
    func crash () throws {
        MSAnalytics.trackEvent("crash-triggered-on-swipe-by-user")
        
        throw MyError.HockeyAppTestError
    }
    
}

