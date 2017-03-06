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

import Foundation

public struct FTCProducts {
    // MARK: Store all products locally to avoid networking problems
    private static let subscriptionsData = [
        [
            "id":"com.ft.ftchinese.mobile.subscription.intelligence2",
            "title":"FT研究院",
            "teaser":"中国商业和消费数据",
            "image":"http://i.ftimg.net/picture/3/000068413_piclink.jpg"
        ]
    ]
    private static let eBooksData = [
        [
            "id":"com.ft.ftchinese.mobile.book.ChinaEconomyAfterFXReform",
            "title":"汇改后的中国经济",
            "teaser":"人民币会继续贬值吗？",
            "image":"http://i.ftimg.net/picture/1/000065581_piclink.jpg",
            "download": "https://creatives.ftimg.net/ads/office/lunch.epub"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.lunch1",
            "title":"与FT共进午餐（一）",
            "teaser":"英国《金融时报》最受欢迎的栏目",
            "image":"http://i.ftimg.net/picture/6/000061936_piclink.jpg",
            "download": "https://creatives.ftimg.net/ads/office/lunch.epub"
        ],
        [
            "id":"com.ft.ftchinese.mobile.book.lunch2",
            "title":"与FT共进午餐（二）",
            "teaser":"英国《金融时报》最受欢迎的栏目",
            "image":"http://i.ftimg.net/picture/7/000061937_piclink.jpg",
            "download": "https://creatives.ftimg.net/ads/office/lunch.epub"
        ]
    ]
    // MARK: - add product group names and titles
    public static let subscriptions = addProductGroup(subscriptionsData, group: "subscription", groupTitle: "订阅")
    public static let eBooks = addProductGroup(eBooksData, group: "ebook", groupTitle: "FT电子书")
    public static let allProducts = subscriptions + eBooks
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = getProductIds(products: allProducts)
    public static let store = IAPHelper(productIds: productIdentifiers)
    
    fileprivate static func addProductGroup(_ products:  [Dictionary<String, String>], group: String, groupTitle: String) -> [Dictionary<String, String>]{
        var newProducts:  [Dictionary<String, String>] = []
        for product in products {
            var newProduct = product
            newProduct["group"] = group
            newProduct["groupTitle"] = groupTitle
            newProducts.append(newProduct)
        }
        return newProducts
    }
    
    fileprivate static func getProductIds(products: [Dictionary<String, String>]) -> Set<ProductIdentifier> {
        var productIds: Set<ProductIdentifier> = []
        for product in products {
            if let productId = product["id"] {
                productIds.insert(productId)
            }
        }
        return productIds
    }
}
