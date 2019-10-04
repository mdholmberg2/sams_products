//
//  ProductsTableViewController.swift
//  SamsProducts
//
//  Created by M D Holmberg II on 10/2/19.
//  Copyright © 2019 M D Holmberg II. All rights reserved.
//

import UIKit

protocol ProductSelectionDelegate: class {
    func productSelected(row: Int)
}

class ProductsTableViewController: UITableViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let presenter = Presenter.shared
    weak var delegate: ProductSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let productCell = UINib(nibName: "ProductTableViewCell", bundle: nil)
        self.tableView.register(productCell, forCellReuseIdentifier: "ProductTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  presenter.numberOfProducts()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as? ProductTableViewCell
        
        cell?.productName.text = presenter.productForRow(row: indexPath.row)
        cell?.productPrice.text = presenter.priceForRow(row: indexPath.row)
        cell?.imageView?.image = presenter.imageForRow(row: indexPath.row).getThumbnail()
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 126.0;
    }
    
    override func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.productSelected(row: indexPath.row)
        
        if let detailViewController = delegate as? ProductViewController {
          splitViewController?.showDetailViewController(detailViewController, sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == presenter.numberOfProducts() {
            if presenter.okToLoad() {
                loadMoreProducts()
            }
        }
    }
    
    func loadMoreProducts() {
        self.activityIndicator.startAnimating()
        self.presenter.loadData()
    }
    
    func showErrorAlert(title: String, message: String) {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ProductsTableViewController: ProductsResult {
    func shouldRefreshList() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    func shouldShowNetworkError(message: String) {
        showErrorAlert(title: "Network Error", message: message)
    }
}

extension UIImage {

  func getThumbnail() -> UIImage? {

    guard let imageData = self.pngData() else { return nil }

    let options = [
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceThumbnailMaxPixelSize: 100] as CFDictionary

    guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
    guard let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }

    return UIImage(cgImage: imageReference)

  }
}

