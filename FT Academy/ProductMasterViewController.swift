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
import StoreKit

class ProductMasterViewController: UITableViewController {
    
    let showDetailSegueIdentifier = "showProductDetail"
    
    var products = [SKProduct]()
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //        if identifier == showDetailSegueIdentifier {
        //            guard let indexPath = tableView.indexPathForSelectedRow else {
        //                return false
        //            }
        //            //let product = products[(indexPath as NSIndexPath).row]
        //            return true
        //            //return FTCProducts.store.isProductPurchased(product.productIdentifier)
        //        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for segue")
        if segue.identifier == showDetailSegueIdentifier {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let product = products[(indexPath as NSIndexPath).row]
            if let detailViewController = segue.destination as? ProductDetailViewController {
                detailViewController.productTitleString = product.localizedTitle
                detailViewController.productIntroString = product.localizedDescription
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "FT中文网电子书"
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ProductMasterViewController.reload), for: .valueChanged)
        
        let restoreButton = UIBarButtonItem(title: "Restore",
                                            style: .plain,
                                            target: self,
                                            action: #selector(ProductMasterViewController.restoreTapped(_:)))
        navigationItem.rightBarButtonItem = restoreButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProductMasterViewController.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
        
        let backButton = UIBarButtonItem(title: "关闭",
                                         style: .plain,
                                         target: self,
                                         action: #selector(ProductMasterViewController.closeTapped(_:)))
        
        navigationItem.leftBarButtonItem = backButton
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reload()
    }
    
    func reload() {
        products = []
        
        tableView.reloadData()
        
        FTCProducts.store.requestProducts{success, products in
            if success {
                self.products = products!
                
                self.tableView.reloadData()
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
    
    func restoreTapped(_ sender: AnyObject) {
        FTCProducts.store.restorePurchases()
    }
    
    func closeTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else { return }
        
        for (index, product) in products.enumerated() {
            guard product.productIdentifier == productID else { continue }
            
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
}

// MARK: - UITableViewDataSource

extension ProductMasterViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // need to hook up the cell to ProductCell class in storyboard
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ProductCell {
            let product = products[(indexPath as NSIndexPath).row]
            
            cell.product = product
            cell.buyButtonHandler = { product in
                FTCProducts.store.buyProduct(product)
            }
            return cell
        }
        print("cannot hook the cell to ProductCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
}
