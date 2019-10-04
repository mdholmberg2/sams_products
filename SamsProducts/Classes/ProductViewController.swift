//
//  ProductViewController.swift
//  SamsProducts
//
//  Created by M D Holmberg II on 10/2/19.
//  Copyright © 2019 M D Holmberg II. All rights reserved.
//

import UIKit
import WebKit

class ProductViewController: UIViewController {
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var reviews: UILabel!
    @IBOutlet weak var inStock: UILabel!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var ratingImageWidth: NSLayoutConstraint!
    @IBOutlet weak var appTitleView: UIView!
    
    
   let presenter = Presenter.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        let shouldHideTitle = UserDefaults.standard.bool(forKey: "titleView")
        if shouldHideTitle {
            appTitleView.isHidden = true
        } else {
            appTitleView.isHidden = false
            let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(titleTapped))
            appTitleView.isUserInteractionEnabled = true
            appTitleView.addGestureRecognizer(tapGestureRecognizer2)
        }
    }
    
    @objc func titleTapped() {
        appTitleView.isHidden = true
        UserDefaults.standard.set(true, forKey: "titleView")
    }
    
    @objc func imageTapped()
    {
        showInfoAlert(title: "Additional Info", message: self.presenter.updateProductLongDescript().html2String)
    }
    
    func showInfoAlert(title: String, message: String) {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ProductViewController: ProductSelectionDelegate {
    func productSelected(row: Int) {
        self.presenter.updateCurrentProduct(row: row)
        shouldRefreshDetail()
    }
}

extension ProductViewController: ProductResult {
    func shouldRefreshDetail() {
        DispatchQueue.main.async {
            self.productName.text = self.presenter.updateProductName()
            self.imageView.image = self.presenter.updateProductImage()
            self.price.text = self.presenter.updateProductPrice()
            self.reviews.text = self.presenter.updateProductReviews()
            self.inStock.text = self.presenter.updateProductInStock()
            self.webView.loadHTMLString(self.presenter.updateProductDescript(), baseURL: nil)
            self.ratingImageWidth.constant = CGFloat(144.0 * (self.presenter.updateProductRating() / 5))
            
            self.view.layoutIfNeeded()
        }
       
    }
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

