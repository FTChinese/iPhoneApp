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
    lazy var backgroundColor: UIColor? = nil
    lazy var durationInSeconds: Double? = nil
    var showSoundButton = true
    lazy var impression: [String] = []
    
    private let adScheduleFileName = "schedule.json"
    private let lauchAdSchedule = "http://m.ftchinese.com/index.php/jsapi/applaunchschedule"
    private let imageTypes = ["png","jpg","gif"]
    private let videoTypes = ["mov","mp4"]
    private let htmlTypes = ["html"]
    
    private var currentPlatform = "iphone"
    
    func parseSchedule() {
        if let scheduleDataFinal = getLatestScheduleData() {
            //Get Current Date in String format of YYYYMMDD
            let dateInString = getCurrentDateString(dateFormat: "yyyyMMdd")
            
            guard let dateInInt = Int(dateInString) else {
                print("date can not be converted to int")
                return
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.currentPlatform = "ipad"
            }
            
            do {
                let JSON = try JSONSerialization.jsonObject(with: scheduleDataFinal, options:JSONSerialization.ReadingOptions(rawValue: 0))
                guard let JSONDictionary: NSDictionary = JSON as? NSDictionary else {
                    print("Not a Dictionary")
                    return
                }
                guard let creatives = JSONDictionary["sections"] as? NSArray else {
                    print("creatives Not an Array")
                    return
                }
                
                // check each crative in the schedule
                for (creative) in creatives {
                    guard let currentCreative = creative as? NSDictionary else {
                        print("creative Not a dictionary")
                        continue
                    }
                    guard var datesString = currentCreative["dates"] as? String else {
                        print("creative dates Not a string")
                        continue
                    }
                    // convert dates string into NSArray for later parsing
                    datesString = datesString.trimmingCharacters(in: .whitespaces)
                        .replacingOccurrences(of: "/", with: "")
                        .replacingOccurrences(of: "-", with: "")
                    let datesStringArray = datesString.components(separatedBy: ",")
                    let dates = datesStringArray.map{ Int($0) ?? 0}
                    
                    var platforms: [String] = []
                    if let supportiPhone = currentCreative["iphone"] as? String {
                        if supportiPhone == "yes" {
                            platforms.append("iphone")
                        }
                    }
                    if let supportiPad = currentCreative["ipad"] as? String {
                        if supportiPad == "yes" {
                            platforms.append("ipad")
                        }
                    }
                    
                    // if this creaive is scheduled for today
                    // and for this type of device(platform)
                    if dates.contains(dateInInt) && platforms.contains(self.currentPlatform){
                        guard var currentFileName = currentCreative["fileName"] as? String else {
                            print("cannot find file name of creative")
                            continue
                        }
                        
                        // on iPad landscape mode, use the landscapeFileName
                        if currentPlatform == "ipad" && UIScreen.main.bounds.width > UIScreen.main.bounds.height {
                            if let landscapeFileName = currentCreative["landscapeFileName"] as? String {
                                if landscapeFileName != "" {
                                    // check if the landscape file is valid and exists locally
                                    let url = NSURL(string:currentFileName)
                                    let pathExtention = url?.pathExtension
                                    let templatePath = checkFilePath(fileUrl: currentFileName)
                                    if templatePath != nil && pathExtention != nil{
                                        currentFileName = landscapeFileName
                                    }
                                }
                            }
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
                            print("found the file in \(templatePath) \(pathExtention)")
                            self.htmlBase = currentFileName
                            self.adLink = currentCreative["click"] as? String ?? ""
                            // background color
                            if let backgroundColorString = currentCreative["backgroundColor"] as? String {
                                if backgroundColorString.range(of: "^#[0-9a-zA-Z]{6}$", options: .regularExpression) != nil {
                                    self.backgroundColor = hexStringToUIColor (hex: backgroundColorString)
                                }
                            }
                            self.impression = []
                            if let impression_1 = currentCreative["impression_1"] as? String {
                                if impression_1 != "" {
                                    self.impression.append(impression_1)
                                }
                            }
                            
                            if let impression_2 = currentCreative["impression_2"] as? String {
                                if impression_2 != "" {
                                    self.impression.append(impression_2)
                                }
                            }
                            if let impression_3 = currentCreative["impression_3"] as? String {
                                if impression_3 != "" {
                                    self.impression.append(impression_3)
                                }
                            }
                            if let durationInString = currentCreative["durationInSeconds"] as? String {
                                if let durationInDouble = Double(durationInString) {
                                    self.durationInSeconds = durationInDouble
                                }
                            }
                            
                            // specific properties like image file, video file, backup image file
                            if imageTypes.contains(pathExtention!.lowercased()) {
                                //print("it is image \(templatePath)")
                                self.adType = "image"
                                self.image = UIImage(contentsOfFile: templatePath!)
                                break
                            } else if htmlTypes.contains(pathExtention!.lowercased()) {
                                self.adType = "page"
                                do {
                                    self.htmlFile = try NSString(contentsOfFile:templatePath!, encoding:String.Encoding.utf8.rawValue)
                                    break
                                } catch {
                                    self.htmlFile = ""
                                }
                            } else if videoTypes.contains(pathExtention!.lowercased()) {
                                self.adType = "video"
                                self.videoFilePath = templatePath!
                                if let backupImageString = currentCreative["backupImage"] as? String {
                                    if let templatePath = checkFilePath(fileUrl: backupImageString) {
                                        self.backupImage = UIImage(contentsOfFile: templatePath)
                                    }
                                }
                                if let showSoundButtonBool = currentCreative["showSoundButton"] as? String {
                                    if showSoundButtonBool == "yes" {
                                        self.showSoundButton = true
                                    } else {
                                        self.showSoundButton = false
                                    }
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
        
    }
    
    // convert a hex string into UIColor
    private func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    private func parseScheduleForDownloading() {
        if let scheduleDataFinal = getLatestScheduleData() {
            //Get Current Date in String format of YYYYMMDD
            let dateInString = getCurrentDateString(dateFormat: "yyyyMMdd")
            let dateInInt = Int(dateInString)!
            do {
                let JSON = try JSONSerialization.jsonObject(with: scheduleDataFinal, options:JSONSerialization.ReadingOptions(rawValue: 0))
                guard let JSONDictionary: NSDictionary = JSON as? NSDictionary else {
                    print("Not a Dictionary")
                    return
                }
                guard let creatives = JSONDictionary["sections"] as? NSArray else {
                    print("creatives Not an Array when parsing for download")
                    return
                }
                // the creatives that are needed for now or a future date
                // other creatives should be deleted
                // the schedule.json file is always needed
                var creativesNeededInFuture = [self.adScheduleFileName]
                // check each creative in the schedule
                
                
                for (creative) in creatives {
                    guard let currentCreative = creative as? NSDictionary else {
                        print("creative Not a dictionary")
                        continue
                    }
                    guard var datesString = currentCreative["dates"] as? String else {
                        print("creative dates Not a string")
                        continue
                    }
                    // convert dates string into NSArray for later parsing
                    datesString = datesString.trimmingCharacters(in: .whitespaces)
                        .replacingOccurrences(of: "/", with: "")
                        .replacingOccurrences(of: "-", with: "")
                    let datesStringArray = datesString.components(separatedBy: ",")
                    let dates = datesStringArray.map{ Int($0) ?? 0}
                    
                    var platforms: [String] = []
                    if let supportiPhone = currentCreative["iphone"] as? String {
                        if supportiPhone == "yes" {
                            platforms.append("iphone")
                        }
                    }
                    if let supportiPad = currentCreative["ipad"] as? String {
                        if supportiPad == "yes" {
                            platforms.append("ipad")
                        }
                    }
                    // check if this creaive is scheduled for today or a later date
                    var creativeIsNeededForFuture = false
                    for dateStamp in dates {
                        if dateStamp >= dateInInt {
                            creativeIsNeededForFuture = true
                        }
                    }
                    
                    // and for this type of device(platform)
                    if creativeIsNeededForFuture == true && platforms.contains(self.currentPlatform){
                        // check to download three types of files
                        if let currentFileName = currentCreative["fileName"] as? String {
                            if let lastComponent = checkCreativeForFuture(currentFileName: currentFileName) {
                                creativesNeededInFuture.append(lastComponent)
                            }
                        }
                        if let currentFileName = currentCreative["landscapeFileName"] as? String {
                            if let lastComponent = checkCreativeForFuture(currentFileName: currentFileName) {
                                creativesNeededInFuture.append(lastComponent)
                            }
                        }
                        if let currentFileName = currentCreative["backupImage"] as? String {
                            if let lastComponent = checkCreativeForFuture(currentFileName: currentFileName) {
                                creativesNeededInFuture.append(lastComponent)
                            }
                        }
                    }
                }
                // delete files that not need for the future
                print("these creative files are needed for a future date: ")
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
                            print("remove file from documents folder: \(creativeFileString)")
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
    }
    
    // check if the creative is needed in the future
    // if it is return true
    // if it is needed but not downloaded yet, download it
    private func checkCreativeForFuture(currentFileName: String) -> String? {
        // extract the file name to figure out the adType
        let url = NSURL(string:currentFileName)
        let pathExtention = url?.pathExtension
        
        // if the file exists locally, return its path. otherwise return nil
        let templatePath = checkFilePath(fileUrl: currentFileName)
        
        // if the file does not exit, download it
        if let lastComponent = url?.lastPathComponent {
            if templatePath == nil && pathExtention != nil{
                // download only when user is using wifi
                let statusType = IJReachability().connectedToNetworkOfType()
                if statusType == .wiFi || !videoTypes.contains(pathExtention!.lowercased()){
                    print("\(currentFileName) about to be downloaded")
                    grabFileFromWeb(url: url as? URL, fileName: lastComponent, parseScheduleForDownload: false)
                }
            }
            return lastComponent
        }
        return nil
    }
    
    private func getLatestScheduleData() -> Data? {
        let scheduleDataFinal: Data?
        let jsonFileTime: Double
        let jsonFileTimeBundle: Double
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
        if jsonFileTime > jsonFileTimeBundle && jsonFileTime > 0 {
            scheduleDataFinal = scheduleData
            print("get schedule from downloaded file")
        } else if jsonFileTimeBundle > 0 {
            scheduleDataFinal = scheduleDataBundle
            print("get schedule from bundled json")
        } else {
            scheduleDataFinal = nil
        }
        return scheduleDataFinal
    }
    
    private func checkFilePath(fileUrl: String) -> String? {
        let url = NSURL(string:fileUrl)
        if let lastComponent = url?.lastPathComponent {
            let templatepathInBuddle = Bundle.main.bundlePath + "/" + lastComponent
            do {
                let DocumentDirURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let templatepathInDocument = DocumentDirURL.appendingPathComponent(lastComponent)
                var templatePath: String? = nil
                if FileManager.default.fileExists(atPath: templatepathInBuddle) {
                    templatePath = templatepathInBuddle
                } else if FileManager().fileExists(atPath: templatepathInDocument.path) {
                    templatePath = templatepathInDocument.path
                }
                return templatePath
            } catch {
                return nil
            }
        }
        return nil
    }
    
    private func readFile(_ fileName: String, fileLocation: String) -> Data? {
        if fileLocation == "download" {
            do {
                let DocumentDirURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileURL = DocumentDirURL.appendingPathComponent(fileName)
                return (try? Data(contentsOf: fileURL))
            } catch {
                return nil
            }
        } else {
            let filename: NSString = fileName as NSString
            let pathExtention = filename.pathExtension
            let pathPrefix = filename.deletingPathExtension
            guard let fileURLBunddle = Bundle.main.path(forResource: pathPrefix, ofType: pathExtention) else {
                return nil
            }
            return (try? Data(contentsOf: URL(fileURLWithPath: fileURLBunddle)))
        }
    }
    
    private func getJSONFileTime(_ jsonData: Data) -> Double {
        do {
            let JSON = try JSONSerialization.jsonObject(with: jsonData, options:JSONSerialization.ReadingOptions(rawValue: 0))
            guard let JSONDictionary: NSDictionary = JSON as? NSDictionary else {
                print("Not a Dictionary")
                return 0
            }
            //print("JSONDictionary! \(JSONDictionary)")
            guard let JSONMeta = JSONDictionary["meta"] as? NSDictionary else {
                print ("No meta in the adchedule json file")
                return 0
            }
            let fileTime = JSONMeta["fileTime"] as? Double ?? 0
            print (fileTime)
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
        grabFileFromWeb(url: urlLauchAdSchedule, fileName: self.adScheduleFileName, parseScheduleForDownload: true)
    }
    
    private func getCurrentDateString(dateFormat: String) -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateInString = dateFormatter.string(from: currentDate)
        return dateInString
    }
    
    private func grabFileFromWeb(url: URL?, fileName: String, parseScheduleForDownload: Bool) {
        if let urlValue = url {
            getDataFromUrl(urlValue) { (data, response, error)  in
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
