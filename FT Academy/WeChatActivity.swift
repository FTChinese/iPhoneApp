import UIKit

class WeChatActivity : UIActivity{
    
    override init() {
        self.text = ""
        
    }
    
    var text:String?
    
    override var activityType: UIActivityType {
        return UIActivityType(rawValue: "WeChat")
    }
    
    override var activityImage: UIImage?
    {
        return UIImage(named: "WeChat")!
    }
    
    override var activityTitle : String
    {
        return "微信好友"
    }
    
    
    override class var activityCategory : UIActivityCategory{
        return UIActivityCategory.share
    }
    
    func getURLFromMessage(_ message:String)-> URL
    {
        var url = "whatsapp://"
        
        if (message != "")
        {
            url = "\(url)send?text=\(message)"
        }
        
        return URL(string: url)!
    }
    
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true;
    }
    
    override func perform() {
        shareToWeChat("ftcweixin://?url=\(webPageUrl)&title=\(webPageTitle)&description=\(webPageDescription)&img=\(webPageImageIcon)&to=chat")
    }
    
}
