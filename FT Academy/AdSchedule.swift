//
//  AdSchedule.swift
//  FT中文网
//
//  Created by ZhangOliver on 2016/10/24.
//  Copyright © 2016年 Financial Times Ltd. All rights reserved.
//

import Foundation
class AdSchedule {
    var adType = "none"
    private let adScheduleFileName = "schedule.json"
    private let lauchAdSchedule = "http://m.ftchinese.com/test.json?4"
    
    func parseSchedule() {
        let scheduleDataFinal: Data
        let jsonFileTime: Int
        let jsonFileTimeBundle: Int
        let scheduleData = readFile(adScheduleFileName, fileLocation: "download")
        let scheduleDataBundle = readFile(adScheduleFileName, fileLocation: "bundle")
        if scheduleData != nil {
            jsonFileTime = getJSONFileTime(scheduleData!)
        } else {
            jsonFileTime = 0
        }
        if scheduleDataBundle != nil {
            jsonFileTimeBundle = getJSONFileTime(scheduleDataBundle!)
        } else {
            jsonFileTimeBundle = 0
        }
        // compare two versions of schedule.json file
        // use whichever is latest
        if jsonFileTime > jsonFileTimeBundle {
            scheduleDataFinal = scheduleData!
            print("get schedule from downloaded file")
        } else {
            scheduleDataFinal = scheduleDataBundle!
            print("get schedule from bundled json")
        }
        
        
        do {
            let JSON = try JSONSerialization.jsonObject(with: scheduleDataFinal, options:JSONSerialization.ReadingOptions(rawValue: 0))
            guard let JSONDictionary: NSDictionary = JSON as? NSDictionary else {
                print("Not a Dictionary")
                return
            }
            guard let creatives = JSONDictionary["creatives"] as? NSArray else {
                print("creatives Not an Array")
                return
            }
            for (creative) in creatives {
                print("This Creative: ")
                print(creative)
            }
        } catch let JSONError as NSError {
            print("\(JSONError)")
        }
        
    }
    private func readFile(_ fileName: String, fileLocation: String) -> Data? {
        if fileLocation == "download" {
            let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = DocumentDirURL.appendingPathComponent(fileName)
            return (try? Data(contentsOf: fileURL))
        } else {
            let filename: NSString = fileName as NSString
            let pathExtention = filename.pathExtension
            let pathPrefix = filename.deletingPathExtension
            guard let fileURLBuddle = Bundle.main.path(forResource: pathPrefix, ofType: pathExtention) else {
                return nil
            }
            return (try? Data(contentsOf: URL(fileURLWithPath: fileURLBuddle)))
        }
    }
    private func getJSONFileTime(_ jsonData: Data) -> Int {
        do {
            let JSON = try JSONSerialization.jsonObject(with: jsonData, options:JSONSerialization.ReadingOptions(rawValue: 0))
            guard let JSONDictionary: NSDictionary = JSON as? NSDictionary else {
                print("Not a Dictionary")
                return 0
            }
            //print("JSONDictionary! \(JSONDictionary)")
            guard let fileTime = JSONDictionary["fileTime"] as? Int else {
                print("No File Time")
                return 0
            }
            return fileTime
        }
        catch let JSONError as NSError {
            print("\(JSONError)")
        }
        return 0
    }
    
    
    // download the latest ad schedule and creatives
    func updateAdSchedule() {
        let urlLauchAdSchedule = URL(string: lauchAdSchedule)
        grabFileFromWeb(urlLauchAdSchedule!)
    }
    private func grabFileFromWeb(_ url: URL) {
        //print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        //weChatShareIcon = UIImage(named: "ftcicon.jpg")
        getDataFromUrl(url) { (data, response, error)  in
            DispatchQueue.main.async { () -> Void in
                guard let data = data , error == nil else { return }
                //print(response?.suggestedFilename ?? "")
                //print(data)
                self.saveFile(data, filename: self.adScheduleFileName)
                //print(data)
                //print("Download Finished")
                //weChatShareIcon = UIImage(data: data)
            }
        }
    }
    private func saveFile(_ data: Data, filename: String) {
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent(filename)
        let fileManager = FileManager.default
        let created = fileManager.createFile(atPath: jsonFilePath.absoluteString, contents: nil, attributes: nil)
        if created {
            //print("File created ")
        } else {
            //print("Couldn't create file for some reason")
        }
        // Write that JSON to the file created earlier
        do {
            let file = try FileHandle(forWritingTo: jsonFilePath)
            file.write(data)
            //print("JSON data was written to the file successfully!")
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
    }
    
}
