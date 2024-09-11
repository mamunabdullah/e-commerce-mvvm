//
//  CategorizedViewController.swift
//  LeadsE-Commerce
//
//  Created by Abdullah Al-Mamun on 5/9/24.
//

import UIKit

class CategorizedViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var viewModel = CategorizedViewModel()
        
        // MARK: - Life cycle
        override func viewDidLoad() {
            super.viewDidLoad()
            tableViewCellSetup()
            setupViewModel()
        }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure the selected category is displayed
        categoryNameLabel.text = viewModel.categoryName
        
        // Fetch products for the selected category
        viewModel.fetchCategoryProducts()
    }
    
    

        // MARK: - Setup Methods
        func tableViewCellSetup() {
            tableView.register(UINib(nibName: K.TableView.categorizedTableViewCell, bundle: nil), forCellReuseIdentifier: K.TableView.categorizedTableViewCell)
            tableView.dataSource = self
            tableView.delegate = self
        }
        
        func setupViewModel() {
            // Set the selected category from previous screen
            viewModel.selectedCategory = getSelectedCategory()
            
            // Update category label
            categoryNameLabel.text = viewModel.categoryName
            
            // Bind ViewModel's closure to reload table view
            viewModel.reloadTableViewClosure = { [weak self] in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        
        func getSelectedCategory() -> String {
            // Retrieve the selected category passed from the previous screen
            // You might have a better way to pass this data
            return viewModel.selectedCategory
        }
        
        // Navigation to Product Detail
        func navigateToProductDetail(with id: Int) {
            ProductDetailViewController.selectedProductID = id
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: K.Segues.productDetailViewController)
            show(vc, sender: self)
        }
    }

    // MARK: - UITableViewDataSource
    extension CategorizedViewController: UITableViewDataSource {

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
             return viewModel.filteredProductList.count
        }
            
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.TableView.categorizedTableViewCell, for: indexPath) as! CategorizedTableViewCell
            let product = viewModel.filteredProductList[indexPath.row]
            cell.productNameLabel.text = product.title
            cell.productDescriptionLabel.text = product.description
            cell.productRateLabel.text = "⭐️ \(product.rate ?? 0.0)"
            cell.productPriceLabel.text = "\(product.price ?? 0.0)$"
            
            if let imageUrlString = product.image, let imageUrl = URL(string: imageUrlString) {
                cell.loadImage(from: imageUrl)
            } else {
                cell.productImageView.image = UIImage(systemName: "photo")
            }
            return cell
        }
    }

    // MARK: - UITableViewDelegate
    extension CategorizedViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let productId = viewModel.filteredProductList[indexPath.row].id {
                navigateToProductDetail(with: productId)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
