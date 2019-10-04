//
//  Interactor.swift
//  SamsProducts
//
//  Created by M D Holmberg II on 10/2/19.
//  Copyright © 2019 M D Holmberg II. All rights reserved.
//

import Foundation
import UIKit

protocol ApiResult: class {
    func didReceiveResponse()
    func didReceiveError(message: String)
}

class Interactor {
    private let productsUrl = "https://mobile-tha-server.firebaseapp.com"
    
    private var pageSize = 0
    private var pageNumber = 0
    private var totalProducts = 0
    
    private var products = [Product]()
    
    var delegate: ApiResult? = nil
    
    func getProducts(page: Int, products: Int) {
        var request = URLRequest(url: URL(string: "\(productsUrl)/walmartproducts/\(page)/\(products)")!)
        
        request.httpMethod = "GET"
        
        // check for networking error
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                self.delegate?.didReceiveError(message: "\(error!)")
                return
            }
            
            // check for http errors
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                self.delegate?.didReceiveError(message: "Status code is \(response!).")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            
            let dataItems = self.convertToDictionary(text: responseString!)
            
            if let dataItems = dataItems {
                self.updatePageInfo(response: dataItems)
                self.buildDataItems(data: dataItems)
            }
        }
        task.resume()
        
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func buildDataItems(data: Dictionary<String, Any>) {
        
        let items = data["products"] as! NSArray
                        
        for item in items {
            let product = item as! Dictionary<String, Any>
            
            let name = product["productName"]
            let productId = product["productId"]
            let shortDescription = product["shortDescription"]
            let longDescription = product["longDescription"]
            let inStock: Bool = product["inStock"] as! Bool
            let price = product["price"]
            let reviewCount = product["reviewCount"]
            let reviewRating = product["reviewRating"]
            let productImage = product["productImage"]
            
            let productItem = Product(
                productId: stringItem(item: productId),
                productName: stringItem(item: name),
                shortDescription: stringItem(item: shortDescription),
                longDescription: stringItem(item: longDescription),
                inStock: inStock,
                price: stringItem(item: price),
                reviewCount: intItem(item: reviewCount),
                reviewRating: floatItem(item: reviewRating).floatValue)
            
            productItem.image = getImage(loc: productImage)
            
            self.products.append(productItem)
            
        }
        
        self.delegate?.didReceiveResponse()
    }
    
    func stringItem(item: Any?) -> String {
        if let item = item {
            return item as! String
        } else {
            return ""
        }
    }
    
    func intItem(item: Any?) -> Int {
        if let item = item {
            return item as! Int
        } else {
            return 0
        }
    }
    
    func floatItem(item: Any?) -> NSNumber {
        if let item = item {
            return item as! NSNumber
        } else {
            return 0
        }
    }
    
    func getImage(loc: Any?) -> UIImage? {
        if let loc = loc {
            let urlString = "\(productsUrl)\(loc)"
            let url = URL(string: urlString)
            let data = try? Data(contentsOf: url!)
            return UIImage(data: data!)
            
        } else {
            return nil
        }
    }
    
    func updatePageInfo(response: Dictionary<String, Any>) {
        self.pageSize = response["pageSize"] as! Int
        self.pageNumber = response["pageNumber"] as! Int
        self.totalProducts = response["totalProducts"] as! Int
    }
    
    func maxProducts() -> Int {
        return self.totalProducts
    }
    
    func numberOfProducts() -> Int {
        return self.products.count
    }
    
    func productItem(row: Int) -> String {
        return self.products[row].productName
    }
    
    func productImage(row: Int) -> UIImage {
        if let image = self.products[row].image {
            return image
        } else {
            return  UIImage(systemName: "photo")!
        }
    }
    
    func productPrice(row: Int) -> String {
        return self.products[row].price
    }
    
    func productReviews(row: Int) -> Int {
        return self.products[row].reviewCount
    }
    
    func productInStock(row: Int) -> Bool {
        return self.products[row].inStock
    }
    
    func productDescript(row: Int) -> String {
        return self.products[row].shortDescription
    }
    
    func productLongDescript(row: Int) -> String {
        return self.products[row].longDescription
    }
    
    func productRating(row: Int) -> Float {
        return self.products[row].reviewRating
    }
}

