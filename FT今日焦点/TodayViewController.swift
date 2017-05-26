//
//  TodayViewController.swift
//  FT今日焦点
//
//  Created by Oliver Zhang on 2017/5/23.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var todayTableView: UITableView!
    
    private let appGroupName = "group.com.ft.ftchinese.mobile"
    private let languageKeyName = "prefer language"
    private let itemsKeyName = "widget items"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.todayTableView.delegate = self
        self.todayTableView.dataSource = self
        let savedItems = UserDefaults.init(suiteName: appGroupName)?.array(forKey: languageKeyName)
        if let savedItems = savedItems as? [[String: String]] {
            self.items = savedItems
            self.todayTableView.reloadData()
        }
    }
    
    private var items = [[String: String]]()
    //private var items = [["image": "ddfa", "title": "title overdfa"]]
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        
        
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
        
        completionHandler(NCUpdateResult.newData)
        
        
    }
    
    // For iOS 10
    @available(iOS 10.0, *)
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        print ("now display \(activeDisplayMode)")
        self.preferredContentSize = (activeDisplayMode == .expanded) ? CGSize(width: maxSize.width, height: CGFloat(items.count)*110) : CGSize(width: maxSize.width, height: 110)
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
            self.items = items
            UserDefaults.init(suiteName: appGroupName)?.set(items, forKey: itemsKeyName)
            self.todayTableView.reloadData()
            //coverItem.text = items[0]["headline"]
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "widget items", for: indexPath) as! TodayItemCell
        let index = indexPath.row
        let tags = items[index]["tag"] ?? ""
        let tag = tags.replacingOccurrences(of: "[,].*$", with: "", options: .regularExpression)
        cell.title.text = items[index]["headline"]
        cell.topic.text = tag
        
        if let imageUrl = items[index]["image"] {
            cell.thumbnail.imageFromServerURL(urlString: "https://www.ft.com/__origami/service/image/v2/images/raw/\(imageUrl)?source=ftchinese&width=208&height=156&fit=cover")
        }
        
        let tapGesture = MyTapGestureRecognizer(target: self, action: #selector(self.tapItem(_:)))
        tapGesture.action = items[index]["type"]
        tapGesture.id = items[index]["id"]
        tapGesture.title = items[index]["headline"]
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
}

class MyTapGestureRecognizer: UITapGestureRecognizer {
    var title: String?
    var action: String?
    var id: String?
}


extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "unknow error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }
}
