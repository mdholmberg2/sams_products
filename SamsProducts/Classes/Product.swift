//
//  Product.swift
//  SamsProducts
//
//  Created by M D Holmberg II on 10/3/19.
//  Copyright © 2019 M D Holmberg II. All rights reserved.
//

import Foundation
import UIKit

class Product: CustomStringConvertible {
    
    let productId: String
    let productName: String
    let shortDescription: String
    let longDescription: String
    let inStock: Bool
    let price: String
    let reviewCount: Int
    let reviewRating: Float
    
    var image: UIImage?
    
    var description: String {
        return "<\(type(of: self)): productName = \(productName) \nproductId = \(productId) \ninStock = \(inStock) \nreviewCount = \(reviewCount) \nreviewRating = \(reviewRating) \nshortDescription = \(shortDescription)>"
    }
    
    init(productId: String,
         productName: String,
         shortDescription: String,
         longDescription: String,
         inStock: Bool,
         price: String,
         reviewCount: Int,
         reviewRating: Float) {
        
        self.productId = productId
        self.productName = productName
        self.shortDescription = shortDescription
        self.longDescription = longDescription
        self.inStock = inStock
        self.price = price
        self.reviewCount = reviewCount
        self.reviewRating = reviewRating
    }
    
}
