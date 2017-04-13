//
//  ShareHelper.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/13.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
struct ShareHelper {
    // MARK: - Update some global variables and return the url with campaign code
    public func getUrl(_ from: String) -> URL? {
        let originalURL = from
        var queryStringDictionary = ["url":""]
        let urlComponents = originalURL.replacingOccurrences(of: "iosaction://?", with: "").components(separatedBy: "&")
        for keyValuePair in urlComponents {
            let stringSeparate = (keyValuePair as AnyObject).range(of: "=").location
            if (stringSeparate>0 && stringSeparate < 100) {
                let pairKey = (keyValuePair as NSString).substring(to: stringSeparate)
                let pairValue = (keyValuePair as NSString).substring(from: stringSeparate+1)
                queryStringDictionary[pairKey] = pairValue.removingPercentEncoding
            }
        }
        // MARK: - update some global variables
        webPageUrl = queryStringDictionary["url"]?.removingPercentEncoding ?? webPageUrl
        webPageTitle = queryStringDictionary["title"] ?? webPageTitle
        webPageDescription = queryStringDictionary["description"] ?? webPageDescription0
        webPageImage = queryStringDictionary["img"] ?? webPageImageIcon0
        webPageImageIcon = webPageImage
        
        let ccodeInActionSheet = ccode["actionsheet"] ?? "iosaction"
        let urlWithCCode = "\(webPageUrl)#ccode=\(ccodeInActionSheet)"
        let url = URL(string: urlWithCCode)
        return url
    }
    
    // MARK: - Pop up the action sheet for share
    public func popupActionSheet(_ fromViewController: UIViewController, url: URL?) {
        let wcActivity = WeChatShare(to: "chat")
        let wcCircle = WeChatShare(to: "moment")
        let openInSafari = OpenInSafari()
        if let myWebsite = url {
            let shareData = DataForShare()
            let image = ShareImageActivityProvider(placeholderItem: UIImage(named: "ftcicon.jpg")!)
            let objectsToShare = [shareData, myWebsite, image] as [Any]
            let activityVC: UIActivityViewController
            if WXApi.isWXAppSupport() == true {
                activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [wcActivity, wcCircle, openInSafari])
            } else {
                activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [openInSafari])
            }
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            if UIDevice.current.userInterfaceIdiom == .pad {
                //self.presentViewController(controller, animated: true, completion: nil)
                let popup: UIPopoverController = UIPopoverController(contentViewController: activityVC)
                popup.present(from: CGRect(x: fromViewController.view.frame.size.width / 2, y: fromViewController.view.frame.size.height / 4, width: 0, height: 0), in: fromViewController.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
            } else {
                fromViewController.present(activityVC, animated: true, completion: nil)
            }
            
            // MARK: - Use the time between action sheet popped and share action clicked to grab the image icon
            if webPageImageIcon.range(of: "https://image.webservices.ft.com") == nil{
                webPageImageIcon = "https://image.webservices.ft.com/v1/images/raw/\(webPageImageIcon)?source=ftchinese&width=72&height=72"
            }
            if let imgUrl = URL(string: webPageImageIcon) {
                updateWeChatShareIcon(imgUrl)
            }
        }
    }
}
