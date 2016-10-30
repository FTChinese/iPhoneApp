//
//  AdSchedule.swift
//  FT中文网
//
//  Created by ZhangOliver on 2016/10/24.
//  Copyright © 2016年 Financial Times Ltd. All rights reserved.
//

import Foundation
class AdSchedule {
    // common properties for all types of creatives
    var adType = "none"
    var htmlBase = ""
    var adLink = ""
    
    // specific properties for each type of creative
    lazy var image: UIImage? = nil
    var htmlFile: NSString = ""
    var videoFilePath = ""
    lazy var backupImage: UIImage? = nil
    var showSoundButton = true
    lazy var impression: [String] = []
    
    private let adScheduleFileName = "schedule.json"
    private let lauchAdSchedule = "http://m.ftchinese.com/test.json"
    private let imageTypes = ["png","jpg","gif"]
    private let videoTypes = ["mov","mp4"]
    private let htmlTypes = ["html"]
    
    private var currentPlatform = "iphone"
    
    func parseSchedule() {
        
        let scheduleDataFinal = getLatestScheduleData()
        
        //Get Current Date in String format of YYYYMMDD
        let dateInString = getCurrentDateString(dateFormat: "yyyyMMdd")
        let dateInInt = Int(dateInString)!
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.currentPlatform = "ipad"
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
            // check each crative in the schedule
            for (creative) in creatives {
                guard let currentCreative = creative as? NSDictionary else {
                    print("creative Not a dictionary")
                    continue
                }
                guard let dates = currentCreative["dates"] as? NSArray else {
                    print("creative dates Not an Array")
                    continue
                }
                guard let platforms = currentCreative["platforms"] as? NSArray else {
                    print("creative platforms Not an Array")
                    continue
                }
                // if this creaive is scheduled for today
                // and for this type of device(platform)
                if dates.contains(dateInInt) && platforms.contains(self.currentPlatform){
                    guard let currentFileName = currentCreative["fileName"] as? String else {
                        print("cannot find file name of creative")
                        continue
                    }
                    
                    // extract the file name to figure out the adType
                    let url = NSURL(string:currentFileName)
                    let pathExtention = url?.pathExtension
                    
                    // if the file exists locally
                    // return its path
                    // otherwise return nil
                    let templatePath = checkFilePath(fileUrl: currentFileName)
                    // if the file exits
                    if templatePath != nil && pathExtention != nil{
                        // common properties like htmlBase, impressions and links
                        self.htmlBase = currentFileName
                        self.adLink = currentCreative["click"] as? String ?? ""
                        self.impression = currentCreative["impression"] as? Array ?? []
                        
                        // specific properties like image file, video file, backup image file
                        if imageTypes.contains(pathExtention!.lowercased()) {
                            //print("it is image \(templatePath)")
                            self.adType = "image"
                            self.image = UIImage(contentsOfFile: templatePath!)
                            break
                        } else if htmlTypes.contains(pathExtention!.lowercased()) {
                            self.adType = "page"
                            self.htmlFile = try! NSString(contentsOfFile:templatePath!, encoding:String.Encoding.utf8.rawValue)
                            break
                        } else if videoTypes.contains(pathExtention!.lowercased()) {
                            self.adType = "video"
                            self.videoFilePath = templatePath!
                            if let backupImageString = currentCreative["backupImage"] as? String {
                                if let templatePath = checkFilePath(fileUrl: backupImageString) {
                                    self.backupImage = UIImage(contentsOfFile: templatePath)
                                }
                            }
                            if let showSoundButtonBool = currentCreative["showSoundButton"] as? Bool {
                                self.showSoundButton = showSoundButtonBool
                            }
                            break
                        }
                        
                        
                    }
                }
            }
        } catch let JSONError as NSError {
            print("\(JSONError)")
        }
        
    }
    
    private func parseScheduleForDownloading() {
        let scheduleDataFinal = getLatestScheduleData()
        //Get Current Date in String format of YYYYMMDD
        let dateInString = getCurrentDateString(dateFormat: "yyyyMMdd")
        let dateInInt = Int(dateInString)!
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
            // the creatives that are needed for now or a future date
            // other creatives should be deleted
            // the schedule.json file is always needed
            var creativesNeededInFuture = [self.adScheduleFileName]
            // check each crative in the schedule
            for (creative) in creatives {
                guard let currentCreative = creative as? NSDictionary else {
                    print("creative Not a dictionary")
                    continue
                }
                guard let dates = currentCreative["dates"] as? NSArray else {
                    print("creative dates Not an Array")
                    continue
                }
                guard let platforms = currentCreative["platforms"] as? NSArray else {
                    print("creative platforms Not an Array")
                    continue
                }
                // check if this creaive is scheduled for today or a later date
                var creativeIsNeededForFuture = false
                for dateStamp in (dates as? [Int])! {
                    if dateStamp >= dateInInt {
                        creativeIsNeededForFuture = true
                    }
                }
                
                // and for this type of device(platform)
                if creativeIsNeededForFuture == true && platforms.contains(self.currentPlatform){
                    guard let currentFileName = currentCreative["fileName"] as? String else {
                        print("cannot find file name of creative")
                        continue
                    }
                    // extract the file name to figure out the adType
                    let url = NSURL(string:currentFileName)
                    let pathExtention = url?.pathExtension
                    
                    // if the file exists locally, return its path. otherwise return nil
                    let templatePath = checkFilePath(fileUrl: currentFileName)
                    // if the file does not exit, download it
                    
                    if let lastComponent = url?.lastPathComponent {
                        if templatePath == nil && pathExtention != nil{
                            let statusType = IJReachability().connectedToNetworkOfType()
                            // download only when user is using wifi
                            if statusType == .wiFi {
                                print("\(currentFileName) about to be downloaded")
                                grabFileFromWeb(url: url as! URL, fileName: lastComponent, parseScheduleForDownload: false)
                            }
                        }
                        creativesNeededInFuture.append(lastComponent)
                    }
                }
            }
            // delete files that not need for the future
            print(creativesNeededInFuture)
            
            // Get the document directory url
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            do {
                // Get the directory contents urls (including subfolders urls)
                let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
                // print(directoryContents)
                
                // if you want to filter the directory contents you can do like this:
                let creativeTypes = videoTypes + htmlTypes + imageTypes
                let creativeFiles = directoryContents.filter{ creativeTypes.contains($0.pathExtension) }
                
                for creativeFile in creativeFiles {
                    // print(creativeFile.lastPathComponent)
                    let creativeFileString = creativeFile.lastPathComponent
                    if !creativesNeededInFuture.contains(creativeFileString) {
                        try FileManager.default.removeItem(at: creativeFile)
                        print("remove file: \(creativeFileString)")
                    }
                }
                // print("creatives:",creativeFiles)
                //                let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
                //                print("mp3 list:", mp3FileNames)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        } catch let JSONError as NSError {
            print("\(JSONError)")
        }
    }
    
    private func getLatestScheduleData() -> Data {
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
        return scheduleDataFinal
    }
    
    private func checkFilePath(fileUrl: String) -> String? {
        let url = NSURL(string:fileUrl)
        let lastComponent = url?.lastPathComponent
        let templatepathInBuddle = Bundle.main.bundlePath + "/" + lastComponent!
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let templatepathInDocument = DocumentDirURL.appendingPathComponent(lastComponent!)
        var templatePath: String? = nil
        if FileManager.default.fileExists(atPath: templatepathInBuddle)
        {
            templatePath = templatepathInBuddle
        } else if FileManager().fileExists(atPath: templatepathInDocument.path) {
            templatePath = templatepathInDocument.path
        }
        return templatePath
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
        let dateInString = getCurrentDateString(dateFormat: "yyyyMMddHHmm")
        let urlString = lauchAdSchedule + "?" + dateInString
        let urlLauchAdSchedule = URL(string: urlString)
        grabFileFromWeb(url: urlLauchAdSchedule!, fileName: self.adScheduleFileName, parseScheduleForDownload: true)
    }
    
    private func getCurrentDateString(dateFormat: String) -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateInString = dateFormatter.string(from: currentDate)
        return dateInString
    }
    
    private func grabFileFromWeb(url: URL, fileName: String, parseScheduleForDownload: Bool) {
        //print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        //weChatShareIcon = UIImage(named: "ftcicon.jpg")
        getDataFromUrl(url) { (data, response, error)  in
            DispatchQueue.main.async { () -> Void in
                guard let data = data , error == nil else { return }
                self.saveFile(data, filename: fileName)
                print ("file saved as \(fileName)")
                if parseScheduleForDownload == true {
                    //print("\(fileName) should be parsed for downloading creatives")
                    self.parseScheduleForDownloading()
                }
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
