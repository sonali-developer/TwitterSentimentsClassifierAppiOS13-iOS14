//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    //Twitter properties
    private var secrets: [String: String] = [:]
    let tweetClassifier = TweeterSentimentClassifier()
    var consumerKey = ""
    var consumerSecret = ""
    let tweetCount = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        self.fetchSecrets()
        guard let tweetConsumerKey = secrets["API Key"], let tweetConsumerSecret = secrets["API Secret"] else {
             fatalError("Couldn't downcast values of secrets to String")
         }
       
        consumerKey = tweetConsumerKey
        consumerSecret = tweetConsumerSecret
    }

    func fetchSecrets() {

            guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
                print("Path not found")
                return
            }

            guard let dictionary = NSDictionary(contentsOfFile: path) else {
                print("Unable to get dictionary from path")
                return
            }
        
            guard let secretDict = dictionary as? [String: String] else {
                fatalError("Couldn't unwrap plist to dictionary")
            }
        
            self.secrets = secretDict
            print(secrets)
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        self.fetchTweets()
    }
    
    func fetchTweets() {
        if let searchText = textField.text {
            let swifter = Swifter(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret)
            swifter.searchTweet(using: searchText, lang: "en", count: self.tweetCount, tweetMode: .extended) { (result, metadata) in
                 
                 var tweets = [TweeterSentimentClassifierInput]()
                 
                for i in 0..<self.tweetCount {
                     if let tweet = result[i]["full_text"].string {
                         let tweetForClassification = TweeterSentimentClassifierInput(text: tweet)
                         tweets.append(tweetForClassification)
                     }
                 }
                 
                self.makePredictions(tweets: tweets)
                 
             } failure: { (error) in
                 print("Failed at getting tweets from twitter - \(error.localizedDescription)")
             }
        }
    }
    
    func makePredictions(tweets: [TweeterSentimentClassifierInput]) {
        do {
            let results = try self.tweetClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            for prediction in results {
                
                let sentiment = prediction.label
                
                switch sentiment {
                case "Pos":
                    sentimentScore += 1
                case "Neg":
                    sentimentScore -= 1
                default:
                    sentimentScore += 0
                }
            }
            
            print(sentimentScore)
            self.updateUI(with: sentimentScore)
           
        } catch {
            print("Error classifying tweets - \(error.localizedDescription)")
        }
    }
    
    func updateUI(with sentimentScore: Int) {
        
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😆"
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😊"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "🤨"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😕"
        } else if sentimentScore > -30 {
            self.sentimentLabel.text = "☹️"
        } else {
            self.sentimentLabel.text = "🤮"
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
}

