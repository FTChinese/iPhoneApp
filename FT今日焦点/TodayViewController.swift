//
//  TodayViewController.swift
//  FT今日焦点
//
//  Created by Oliver Zhang on 2017/5/23.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var coverItem: UILabel!
    private var items = ["cover 1", "cover 2", "cover 3"]
    private let appGroupName = "group.com.ft.ftchinese.mobile"
    private let languageKeyName = "prefer language"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        // MARK: - Check if the user prefers traditional Chinese
        let pre = UserDefaults.init(suiteName: appGroupName)?.string(forKey: languageKeyName) ?? Locale.preferredLanguages[0]
        let coverAPIString: String
        if pre.hasPrefix("zh-Hant") {
            coverAPIString = "https://m.ftimg.net/index.php/jsapi/wiget"
        } else {
            coverAPIString = "https://m.ftimg.net/index.php/jsapi/wiget"
        }
        
        
        getCoverItems(coverAPIString)
        
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
        
        
//        if let pre = UserDefaults.init(suiteName: appGroupName)?.string(forKey: languageKeyName) {
//            if pre.hasPrefix("zh-Hant") {
//                coverItem.text = "繁体中文1"
//            } else {
//                coverItem.text = "简体中文1"
//            }
//        } else {
//            coverItem.text = "简体中文1"
//            completionHandler(NCUpdateResult.newData)
//        }
        
    }
    
    // For iOS 10
    @available(iOS 10.0, *)
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        print ("now display \(activeDisplayMode)")
        self.preferredContentSize = (activeDisplayMode == .expanded) ? CGSize(width: 320, height: CGFloat(items.count)*121 + 44) : CGSize(width: maxSize.width, height: 110)
    }
    
    
    private func getDataFromUrl(_ url:URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: NSError? ) -> Void)) {
        let listTask = URLSession.shared.dataTask(with: url, completionHandler:{(data, response, error) in
            completion(data, response, error as NSError?)
            return ()
        })
        listTask.resume()
    }
    
    private func getCoverItems(_ urlString: String) {
        let url = URL(string: urlString)
        if let urlValue = url {
            getDataFromUrl(urlValue) { (data, response, error)  in
                DispatchQueue.main.async { () -> Void in
                    guard let data = data , error == nil else { return }
                    self.handleJSONData(data)
                }
            }
        }
    }
    
    private func handleJSONData(_ data: Data) {
        do {
            let JSON = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue: 0))
            guard let items = JSON as? [Dictionary<String, String>] else {
                print("Not a Dictionary")
                return
            }
            coverItem.text = items[0]["headline"]
            let tapGesture = MyTapGestureRecognizer(target: self, action: #selector(self.tapItem(_:)))
            tapGesture.action = items[0]["type"]
            tapGesture.id = items[0]["id"]
            tapGesture.title = items[0]["headline"]
            coverItem.isUserInteractionEnabled = true
            coverItem.addGestureRecognizer(tapGesture)
        } catch let JSONError as NSError {
            print("\(JSONError)")
        }
    }
    
    
    func tapItem(_ sender: MyTapGestureRecognizer) {
        let action = sender.action ?? "unknown"
        let id = sender.id ?? ""
        if let url = URL(string: "ftchinese://\(action)/\(id)") {
            self.extensionContext!.open(url,completionHandler: nil)
        }
    }
    
}

class MyTapGestureRecognizer: UITapGestureRecognizer {
    var title: String?
    var action: String?
    var id: String?
}
