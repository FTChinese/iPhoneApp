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

import UIKit

class ProductDetailViewController: UIViewController {
    



    @IBOutlet weak var productTitle: UILabel?
    
    @IBOutlet weak var productIntro: UILabel?
    
    var productTitleString: String? {
        didSet {
            configureView()
        }
    }
    lazy var productIntroString: String? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        //productTitle.text = productTitleString
        print("configure view for \(productTitleString)")
        if let productTitleString = productTitleString,
            let productTitle = productTitle {
            //productTitle.text = productTitleString
            productTitle.text = productTitleString
        }
        if let productIntroString = productIntroString,
            let productIntro = productIntro {
            //productTitle.text = productTitleString
            print(productIntroString)
            productIntro.text = productIntroString
        }
        
    }
}
