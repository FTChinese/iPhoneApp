//
//  DownloadHelper.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/14.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation

class DownloadHelper: NSObject,URLSessionDownloadDelegate {
    
    public var directory: String
    public let downloadStatusNotificationName = "download status change"
    public let downloadProgressNotificationName = "download progress change"
    public var currentStatus = "remote"
    
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
    
    public func startDownload(_ url: String) {
        if let u = URL(string: url) {
            let fileName = u.lastPathComponent
            if let localFileLocation = checkDownloadedFileInDirectory(url) {
                // TODO: the file is already downloaded, delete it
                removeDownloadedFile(localFileLocation)
                postStatusChange(["id": fileName, "status":"remote"])
            } else {
                // MARK: - Download the file through the internet
                print ("The file does not exist. Download from \(url)")
                let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: fileName)
                let backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: downloadQueue)
                let request = URLRequest(url: u)
                downloadTasks[url] = backgroundSession.downloadTask(with: request)
                downloadTasks[url]?.resume()
                print ("downloading")
                postStatusChange(["id": fileName, "status":"downloading"])
                // TODO: track the action of download
            }
        } else {
            // TODO: the url is not the right format, do some error handling
            print ("the file is already downloaded, update the ui to reflect that")
            postStatusChange(["id": "unknown", "status":"error"])
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
                currentStatus = "success"
                return templatePath
            } catch {
                currentStatus = "remote"
                return nil
            }
        }
        currentStatus = "remote"
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
        if let productId = session.configuration.identifier {
            let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentDirectoryPath:String = path[0]
            let fileManager = FileManager()
            let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/\(productId)"))
            
            print ("\(productId) file downloaded to: \(location.absoluteURL)")
            if fileManager.fileExists(atPath: destinationURLForFile.path){
                print ("the file exists, you can open it. ")
                postStatusChange(["id": productId, "status":"success"])
            } else {
                do {
                    try fileManager.moveItem(at: location, to: destinationURLForFile)
                    // MARK: - Update UI and track download success
                    print("download success")
                    postStatusChange(["id": productId, "status":"success"])
                }catch{
                    print("An error occurred while moving file to destination url")
                    // MARK: - Update UI and track saving failure
                    postStatusChange(["id": productId, "status":"failure"])
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
            if downloadProgresses[productId] != totalMBsWritten {
                downloadProgresses[productId] = totalMBsWritten
                let totalMBsExpectedToWrite = String(format: "%.1f", Float(totalBytesExpectedToWrite)/1000000)
                // TODO: Post notification about progress change
                let progressStatus: [String: Any] = [
                    "id": productId,
                    "percentage": percentageNumber,
                    "downloaded": totalMBsWritten,
                    "total": totalMBsExpectedToWrite
                ]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: downloadProgressNotificationName), object: progressStatus)
            }
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
                print ("iapActions('\(productId)', 'pendingdownload');")
            }
        }
    }
    
    
    private func postStatusChange(_ status: [String: String]) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: downloadStatusNotificationName), object: status)
    }
    
    // MARK: - Done:  Post and Receive Status Change Notifications
    // TODO: Update UI Based on Status Change
    // TODO: Update UI Based on Download Progress
    // MARK: - Done:  Choose streaming or local file to play based on availability of audio files
    // TODO: Allow users to clean files with one tap
    // TODO: Let users easily find downloaded file to play

    
    // https://www.raywenderlich.com/94302/implement-circular-image-loader-animation-cashapelayer
    // 
}
