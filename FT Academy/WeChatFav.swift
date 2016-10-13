import UIKit

class WeChatFav : UIActivity{
    
    override init() {
        self.text = ""
    }
    
    var text:String?
    
    
    override var activityType: UIActivityType {
        return UIActivityType(rawValue: "WeChatMoment")
    }
    
    override var activityImage: UIImage?
    {
        return UIImage(named: "WeChatFav")!
    }
    
    override var activityTitle : String
    {
        return "微信收藏"
    }
    
    
    override class var activityCategory : UIActivityCategory{
        return UIActivityCategory.action
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
        shareToWeChat("ftcweixin://?url=\(webPageUrl)&title=\(webPageTitle)&description=\(webPageDescription)&img=\(webPageImageIcon)&to=fav")
    }
}
