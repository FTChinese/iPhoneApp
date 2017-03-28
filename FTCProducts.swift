/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

// MARK: - IAP Tutorial 2: FTC's IAP Products Data

import Foundation

public struct FTCProducts {
    // MARK: Store all products locally to avoid networking problems
    private static let subscriptionsData = [
        [
            "id":"com.ft.ftchinese.mobile.subscription.intelligence3",
            "title":"FT研究院",
            "teaser":"中国商业和消费数据",
            "image":"http://i.ftimg.net/picture/3/000068413_piclink.jpg",
            "period":"year"
        ]
    ]
    private static let membershipData = [
        [
            "id":"com.ft.ftchinese.mobile.subscription.premium",
            "title":"高端会员",
            "teaser":"注册成为高端会员",
            "image":"http://i.ftimg.net/picture/6/000068886_piclink.jpg",
            "period":"year",
            "benefits": [
                "会员期间屏蔽全站广告，带来极佳的阅读体验",
                "会员期间免费阅读FT中文网所有付费内容，每篇付费内容有一个免费分享名额",
                "购买FT自有产品享受VIP折扣",
                "购买FT电子书可免费发送至kindle",
                "可选择开启手机客户端专属订制内容推送，你感兴趣的不再错过"
            ]
        ],
        [
            "id":"com.ft.ftchinese.mobile.subscription.standard",
            "title":"普通会员",
            "teaser":"注册成为普通会员",
            "image":"http://i.ftimg.net/picture/6/000068886_piclink.jpg",
            "period":"year",
            "benefits": [
                "会员期间屏蔽部分网站广告，升级阅读体验",
                "会员期间免费阅读付费内容",
                "购买FT电子书可免费发送至kindle",
                "可选择开启手机客户端专属订制内容推送，你感兴趣的不再错过"
            ]
        ],
        [
            "id":"com.ft.ftchinese.mobile.subscription.trial",
            "title":"试读会员",
            "teaser":"注册成为试读会员",
            "image":"http://i.ftimg.net/picture/6/000068886_piclink.jpg",
            "period":"month",
            "benefits": [
                "1个月内屏蔽部分网站广告，升级阅读体验",
                "会员期间免费阅读4篇付费内容",
                "可选择开启手机客户端专属订制内容推送，你感兴趣的不再错过"
            ]
        ]
    ]
    
    private static let eBooksData = [
        [
            "id":"com.ft.ftchinese.mobile.book.OutlookoftheFutureof2017",
            "title":"精选2016，展望2017",
            "teaser":" 2017年，我们熟悉的那个世界是否正在远去？",
            "image":"http://i.ftimg.net/picture/9/000068669_piclink.jpg",
            "download": "https://creatives.ftimg.net/commodity/JingXuan_2016_ZhanWang_2017_YiYiYingGu_FTChinese.epub",
            "downloadfortry": "https://creatives.ftimg.net/commodity/JingXuan_2016_ZhanWang_2017_YiYiYingGu_FTChinese_Short.epub"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.lunch1",
            "title":"与FT共进午餐（一）",
            "teaser":"英国《金融时报》最受欢迎的栏目",
            "image":"http://i.ftimg.net/picture/2/000068702_piclink.jpg",
            "download": "https://creatives.ftimg.net/commodity/Yu_FT_GongJinWuCan_I_FTChinese.epub",
            "downloadfortry": "https://creatives.ftimg.net/commodity/Yu_FT_GongJinWuCan_I_FTChinese_Short.epub"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.lunch2",
            "title":"与FT共进午餐（二）",
            "teaser":"英国《金融时报》最受欢迎的栏目",
            "image":"http://i.ftimg.net/picture/3/000068703_piclink.jpg",
            "download": "https://creatives.ftimg.net/commodity/Yu_FT_GongJinWuCan_II_FTChinese.epub",
            "downloadfortry": "https://creatives.ftimg.net/commodity/Yu_FT_GongJinWuCan_II_FTChinese_Short.epub"
        ]
    ]
    // MARK: - Add product group names and titles
    public static let subscriptions = addProductGroup(subscriptionsData, group: "subscription", groupTitle: "订阅")
    public static let eBooks = addProductGroup(eBooksData, group: "ebook", groupTitle: "FT电子书")
    public static let memberships = addProductGroup(membershipData, group: "membership", groupTitle: "会员")
    
    // MARK: - Combine all types of products into one and request for more information, such as price, from app store
    public static let allProducts = memberships + subscriptions + eBooks
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = getProductIds(products: allProducts)
    public static let store = IAPHelper(productIds: productIdentifiers)
    
    fileprivate static func addProductGroup(_ products:  [Dictionary<String, Any>], group: String, groupTitle: String) -> [Dictionary<String, Any>]{
        var newProducts:  [Dictionary<String, Any>] = []
        for product in products {
            var newProduct = product
            newProduct["group"] = group
            newProduct["groupTitle"] = groupTitle
            newProducts.append(newProduct)
        }
        return newProducts
    }
    
    fileprivate static func getProductIds(products: [Dictionary<String, Any>]) -> Set<ProductIdentifier> {
        var productIds: Set<ProductIdentifier> = []
        for product in products {
            if let productId = product["id"] as? String {
                productIds.insert(productId)
            }
        }
        return productIds
    }
}
