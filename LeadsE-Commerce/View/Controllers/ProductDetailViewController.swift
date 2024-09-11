//
//  ProductDetailViewController.swift
//  LeadsE-Commerce
//
//  Created by Abdullah Al-Mamun on 5/9/24.
//

import UIKit

class ProductDetailViewController: UIViewController {

    //MARK: - Properties
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productSalesCount: UILabel!
    @IBOutlet weak var productRate: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
    static var selectedProductID: Int = 0
        private var viewModel: ProductDetailViewModel!
        
        //MARK: - Life cycle
        override func viewDidLoad() {
            super.viewDidLoad()
            viewModel = ProductDetailViewModel()
            bindViewModel()
            viewModel.fetchProductDetails(selectedId: ProductDetailViewController.selectedProductID)
        }
        
        //MARK: - Interaction handlers
        @IBAction func addBasketButtonClicked(_ sender: UIButton) {
            viewModel.updateCart(productId: ProductDetailViewController.selectedProductID, quantity: 1)
        }
        
        //MARK: - Functions
        func bindViewModel() {
            viewModel.onProductFetched = { [weak self] productData in
                self?.updateUI(with: productData)
            }
            viewModel.onAlertMessage = { [weak self] title, message in
                DuplicateFuncs.alertMessage(title: title, message: message, vc: self!)
            }
        }
        
        func updateUI(with productData: ProductData) {
            if let imageUrl = URL(string: productData.image) {
                loadImage(from: imageUrl, into: self.productImage)
            } else {
                self.productImage.image = UIImage(systemName: "photo")
            }
            self.productRate.text = "⭐️\(productData.rating.rate)"
            self.productPrice.text = "$\(productData.price)"
            self.productTitle.text = productData.title
            self.productDescription.text = productData.description
            self.productSalesCount.text = "\(productData.rating.count) sold"
        }
        
        func loadImage(from url: URL, into imageView: UIImageView) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        imageView.image = UIImage(data: data)
                    }
                } else {
                    DispatchQueue.main.async {
                        imageView.image = UIImage(systemName: "photo")
                    }
                }
            }
            task.resume()
        }
    }
