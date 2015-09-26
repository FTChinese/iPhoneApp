import UIKit

class WeChatActivity : UIActivity{
    
    override init() {
        self.text = ""
        
    }
    
    var text:String?
    
    override func activityType()-> String {
        return "WeChat"
    }
    
    override func activityImage()-> UIImage?
    {
        return UIImage(named: "WeChat")!
    }
    
    override func activityTitle() -> String
    {
        return "微信好友"
    }
    

    override class func activityCategory() -> UIActivityCategory{
        return UIActivityCategory.Action
    }
    
    func getURLFromMessage(message:String)-> NSURL
    {
        var url = "whatsapp://"
        
        if (message != "")
        {
            url = "\(url)send?text=\(message)"
        }
        
        return NSURL(string: url)!
    }
    
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true;
    }

    override func performActivity() {
        shareToWeChat("ftcweixin://?url=\(webPageUrl)&title=\(webPageTitle)&description=\(webPageDescription)&img=\(webPageImageIcon)&to=chat")
    }
    
}