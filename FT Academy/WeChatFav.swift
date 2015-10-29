import UIKit

class WeChatFav : UIActivity{
    
    override init() {
        self.text = ""
    }
    
    var text:String?
    
    
    override func activityType()-> String {
        return "WeChatMoment"
    }
    
    override func activityImage()-> UIImage?
    {
        return UIImage(named: "WeChatFav")!
    }
    
    override func activityTitle() -> String
    {
        return "微信收藏"
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
        shareToWeChat("ftcweixin://?url=\(webPageUrl)&title=\(webPageTitle)&description=\(webPageDescription)&img=\(webPageImageIcon)&to=fav")
    }
}