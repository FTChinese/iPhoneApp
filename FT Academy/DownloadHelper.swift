//
//  DownloadHelper.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/14.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation


enum DownloadStatus {
    case remote
    case downloading
    case paused
    case resumed
    case success
}

class DownloadHelper: NSObject,URLSessionDownloadDelegate {
    
    public var directory: String
    public let downloadStatusNotificationName = "download status change"
    public let downloadProgressNotificationName = "download progress change"
    public var currentStatus: DownloadStatus = .remote
    
    init(directory: String) {
        self.directory = directory
    }
    
    // MARK: - The Download Operation Queue
    private lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // MARK: keep a reference of all the Download Tasks
    private var downloadTasks = [String: URLSessionDownloadTask]()
    
//    public func checkDownloadStatus(_ url: String) {
//        var message = [String: Any]()
//        if let u = URL(string: url) {
//            let fileName = u.lastPathComponent
//            if checkDownloadedFileInDirectory(url) == nil {
//                // MARK: - Should Download the file through the internet
//                print ("The file does not exist. Download from \(url)")
//                message = ["id": fileName, "status": DownloadStatus.remote]
//            } else {
//                print ("file already exists. No need to download. ")
//                message = ["id": fileName, "status": DownloadStatus.success]
//            }
//            postStatusChange(message)
//        }
//    }
    
    public func startDownload(_ url: String) {
        if let u = URL(string: url) {
            let fileName = u.lastPathComponent
            if checkDownloadedFileInDirectory(url) == nil {
                // MARK: - Download the file through the internet
                print ("The file does not exist. Download from \(url)")
                let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: fileName)
                let backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: downloadQueue)
                let request = URLRequest(url: u)
                downloadTasks[url] = backgroundSession.downloadTask(with: request)
                downloadTasks[url]?.resume()
                postStatusChange(fileName, status: .downloading)

                // TODO: track the action of download
            } else {
                print ("file already exists. No need to download. ")
                postStatusChange(fileName, status: .success)
            }
        } else {
            // TODO: the url is not the right format, do some error handling
            print ("the file is already downloaded, update the ui to reflect that")
            postStatusChange("unknown", status: .remote)
        }
    }
    
    public func takeActions(_ url: String, currentStatus: DownloadStatus) {
        print (currentStatus)
        switch currentStatus {
        case .remote:
            startDownload(url)
        case .success:
            removeDownload(url)
        case .downloading, .resumed:
            pauseDownload(url)
        case .paused:
            resumeDownload(url)
        }
    }
    
    public func removeDownload(_ url: String) {
        if let u = URL(string: url) {
            let fileName = u.lastPathComponent
            if let localFileLocation = checkDownloadedFileInDirectory(url) {
                // TODO: the file is already downloaded, delete it
                removeDownloadedFile(localFileLocation)
                postStatusChange(fileName, status: .remote)
            }
        }
    }
    
    public func pauseDownload(_ url: String) {
        if let u = URL(string: url) {
            let fileName = u.lastPathComponent
            downloadTasks[url]?.suspend()
            postStatusChange(fileName, status: .paused)
        }
    }
    
    public func resumeDownload(_ url: String) {
        if let u = URL(string: url) {
            let fileName = u.lastPathComponent
            downloadTasks[url]?.resume()
            postStatusChange(fileName, status: .resumed)
        }
    }
    
    public func checkDownloadedFileInDirectory(_ url: String) -> String? {
        let url = URL(string:url)
        if let lastComponent = url?.lastPathComponent {
            do {
                let DocumentDirURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let templatepathInDocument = DocumentDirURL.appendingPathComponent(lastComponent)
                var templatePath: String? = nil
                if FileManager().fileExists(atPath: templatepathInDocument.path) {
                    templatePath = templatepathInDocument.path
                }
                currentStatus = .success
                return templatePath
            } catch {
                currentStatus = .remote
                return nil
            }
        }
        currentStatus = .remote
        return nil
    }
    
    private func removeDownloadedFile(_ url: String) {
        do {
            let urlFileLocation = URL(fileURLWithPath: url)
            try FileManager.default.removeItem(at: urlFileLocation)
        } catch {
            print ("file \(url) cannot be deleted")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let id = session.configuration.identifier {
            let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentDirectoryPath:String = path[0]
            let fileManager = FileManager()
            let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/\(id)"))
            print ("\(id) file downloaded to: \(location.absoluteURL)")
            if fileManager.fileExists(atPath: destinationURLForFile.path){
                print ("the file exists, you can open it. ")
                postStatusChange(id, status: .success)
            } else {
                do {
                    try fileManager.moveItem(at: location, to: destinationURLForFile)
                    // MARK: - Update UI and track download success
                    print("download success")
                    postStatusChange(id, status: .success)
                }catch{
                    print("An error occurred while moving file to destination url")
                    // MARK: - Update UI and track saving failure
                    postStatusChange(id, status: .resumed)
                }
            }
        }
    }
    
    
    // MARK: - Keep a reference of all the Download Progress
    var downloadProgresses = [String: String]()
    
    // MARK: - Get progress status for download tasks and update UI
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        // MARK: - evaluateJavaScript is very energy consuming, do this only every 1k download
        if let productId = session.configuration.identifier {
            let totalMBsWritten = String(format: "%.1f", Float(totalBytesWritten)/1000000)
            let percentageNumber = 100 * Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            if totalMBsWritten == "0.0" {
                downloadProgresses[productId] = "0.0"
            }
            downloadProgresses[productId] = totalMBsWritten
            let totalMBsExpectedToWrite = String(format: "%.1f", Float(totalBytesExpectedToWrite)/1000000)
            // MARK: - Post notification about progress change
            let progressStatus = (
                id: productId,
                percentage: percentageNumber,
                downloaded: totalMBsWritten,
                total: totalMBsExpectedToWrite
            )
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: downloadProgressNotificationName), object: progressStatus)
            
        }
    }
    
    // MARK: - Deal with errors in download process
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        if (error != nil) {
            print(error!.localizedDescription)
            if let productId = session.configuration.identifier {
                // TODO: Update UI about Download Failure
                postStatusChange(productId, status:DownloadStatus.remote)
            }
        }
    }
    
    
    private func postStatusChange(_ id: String, status: DownloadStatus ) {
        let message = (id: id, status: status)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: downloadStatusNotificationName), object: message)
    }
    

}


// MARK: extension is not ideal, a better solution should be a subclass of UIButton
class UIButtonEnhanced: UIButton {
    var progress: Float = 0 {
        didSet {
            circleShape.strokeEnd = CGFloat(self.progress)
        }
    }
    
    var circleShape = CAShapeLayer()
    public func drawCircle() {
        let x: CGFloat = 0.0
        let y: CGFloat = 0.0
        let circlePath = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: self.frame.height, height: self.frame.height), cornerRadius: self.frame.height / 2).cgPath
        circleShape.path = circlePath
        circleShape.lineWidth = 3
        circleShape.strokeColor = UIColor.white.cgColor
        circleShape.strokeStart = 0
        circleShape.strokeEnd = 0
        circleShape.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(circleShape)
    }
    
    // MARK: - Update the download status
    var status: DownloadStatus = .remote {
        didSet{
            var buttonImageName = ""
            switch self.status {
            case .remote:
                buttonImageName = "DownloadButton"
            case .downloading:
                buttonImageName = "PauseButton"
            case .success:
                buttonImageName = "DeleteButton"
            case .paused:
                buttonImageName = "DownloadButton"
            case .resumed:
                buttonImageName = "PauseButton"
            }
            self.setImage(UIImage(named: buttonImageName), for: .normal)
        }
    }
}

// MARK: - Done:  Update progressSlider thumb image with customized ones
// MARK: - Done:  Post and Receive Status Change Notifications
// MARK: - Done:  Update UI Based on Status Change
// MARK: - Done:  Update UI Based on Download Progress
// MARK: - Done:  Choose streaming or local file to play based on availability of audio files
// TODO: Allow users to clean files with one tap
// TODO: Let users easily find downloaded file to play
// TODO: Display current status so that users/reviewers know what it is going on
// TODO: If a user is trying to download while not on wifi, pop out an alert with friendly suggestions

// https://www.raywenderlich.com/94302/implement-circular-image-loader-animation-cashapelayer
