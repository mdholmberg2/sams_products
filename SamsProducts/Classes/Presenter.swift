//
//  Presenter.swift
//  SamsProducts
//
//  Created by M D Holmberg II on 10/2/19.
//  Copyright © 2019 M D Holmberg II. All rights reserved.
//

import Foundation
import UIKit

protocol ProductResult: class {
    func shouldRefreshDetail()
}

protocol ProductsResult: class {
    func shouldRefreshList()
    func shouldShowNetworkError(message: String)
}

class Presenter {
    static let shared = Presenter()
    
    private let interactor = Interactor()
    
    var productDelegate: ProductResult?
    var productsDelegate: ProductsResult?
    
    private var currentProduct = 0
    private var currentPage = 0
    private let productsPerPage = 10
    
    private var okToLoadFlag = true
    
    init() {
        self.interactor.delegate = self
    }
    
    func loadData() {
        if !okToLoadFlag { return }
        
        currentPage += 1
        okToLoadFlag = false
        self.interactor.getProducts(page: currentPage, products: productsPerPage)
    }
    
    func okToLoad() -> Bool {
        return okToLoadFlag
    }
    
    func updateCurrentProduct(row: Int) {
        currentProduct = row
    }
    
    func numberOfProducts() -> Int {
        return self.interactor.numberOfProducts()
    }
    
    func productForRow(row: Int) -> String {
        return removeSpecialCharsFromString(text: self.interactor.productItem(row: row))
    }
    
    func priceForRow(row: Int) -> String {
        return self.interactor.productPrice(row: row)
    }
    
    func imageForRow(row: Int) -> UIImage {
        return self.interactor.productImage(row: row)
    }
    
    func updateProductName() -> String {
        return removeSpecialCharsFromString(text: self.interactor.productItem(row: currentProduct))
    }
    
    func updateProductImage() -> UIImage {
        return self.interactor.productImage(row: currentProduct)
    }
    
    func updateProductPrice() -> String {
        return self.interactor.productPrice(row: currentProduct)
    }
    
    func updateProductReviews() -> String {
        return "\(self.interactor.productReviews(row: currentProduct))"
    }
    
    func updateProductInStock() -> String {
        return self.interactor.productInStock(row: currentProduct) ? "In Stock" : "On Order"
    }
    
    func updateProductDescript() -> String {
        let stringHTML = "<meta name=\"viewport\" content=\"initial-scale=1.0\" />"
        return "\(stringHTML)\(self.interactor.productDescript(row: currentProduct))"
    }
    
    func updateProductLongDescript() -> String {
        return self.interactor.productLongDescript(row: currentProduct)
    }
    
    func updateProductRating() -> Float {
        return self.interactor.productRating(row: currentProduct)
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
        return text.filter {okayChars.contains($0) }
    }
}

extension Presenter: ApiResult {
    func didReceiveResponse() {
        
        self.productsDelegate?.shouldRefreshList()
        self.productDelegate?.shouldRefreshDetail()
        
        if self.interactor.numberOfProducts() < self.interactor.maxProducts() {
            okToLoadFlag = true
        }
    }
    
    func didReceiveError(message: String) {
        print("didReceiveError... " + message)
        self.productsDelegate?.shouldShowNetworkError(message:  message)
    }
}
