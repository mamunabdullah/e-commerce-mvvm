//
//  HomeViewController.swift
//  LeadsE-Commerce
//
//  Created by Abdullah Al-Mamun on 5/9/24.

import UIKit

class HomeViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var productCollectionView: UICollectionView!
    private var homeViewModel = HomeViewModel()

        override func viewDidLoad() {
            super.viewDidLoad()
            collectionSetup()
            tabBarSetup()

            // Bind ViewModel to UI updates
            homeViewModel.reloadUI = { [weak self] in
                DispatchQueue.main.async {
                    self?.categoryCollectionView.reloadData()
                    self?.productCollectionView.reloadData()
                }
            }

            homeViewModel.fetchCategories()
            homeViewModel.fetchProducts()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // Ensure the data is up-to-date when the view appears
            homeViewModel.fetchCategories()
            homeViewModel.fetchProducts()
        }
           
        //MARK: - CollectionCells Setup
        func collectionSetup() {
            categoryCollectionView.register(UINib(nibName: K.CollectionViews.topCollectionViewNibNameAndIdentifier, bundle: nil), forCellWithReuseIdentifier: K.CollectionViews.topCollectionViewNibNameAndIdentifier)
            categoryCollectionView.collectionViewLayout = TopCollectionViewColumnFlowLayout(sutunSayisi: 2, minSutunAraligi: 5, minSatirAraligi: 5)
            
            productCollectionView.register(UINib(nibName: K.CollectionViews.bottomCollectionViewNibNameAndIdentifier, bundle: nil), forCellWithReuseIdentifier: K.CollectionViews.bottomCollectionViewNibNameAndIdentifier)
            productCollectionView.collectionViewLayout = BottomCollectionViewColumnFlowLayout(sutunSayisi: 2, minSutunAraligi: 5, minSatirAraligi: 5)
        }

        //MARK: - Other functions remain unchanged
        func tabBarSetup() {
            self.tabBarController?.navigationItem.hidesBackButton = true
            tabBarController!.tabBar.items?[1].badgeValue = "0"
        }
        
        // MARK: - Navigation Helpers
        func changeVCcategoryToTableView(category: String) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let categorizedVC = storyboard.instantiateViewController(withIdentifier: "CategoryTableViewVC") as? CategorizedViewController else {
                print("Failed to instantiate CategorizedViewController")
                return
            }
            
            let categorizedVM = CategorizedViewModel()
            categorizedVM.selectedCategory = category
            categorizedVC.viewModel = categorizedVM
            
            navigationController?.pushViewController(categorizedVC, animated: true)
        }

        func changeVCHomeToProductDetail(id: Int) {
            ProductDetailViewController.selectedProductID = id
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: K.Segues.productDetailViewController)
            show(vc, sender: self)
        }
    }

    //MARK: - Extensions
    extension HomeViewController: UICollectionViewDataSource {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            switch collectionView {
            case categoryCollectionView:
                return homeViewModel.categoryList.count
            case productCollectionView:
                return homeViewModel.productList.count
            default:
                return 0
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            switch collectionView {
            case categoryCollectionView:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.CollectionViews.topCollectionViewNibNameAndIdentifier, for: indexPath) as! CategoriesCollectionViewCell
                let category = homeViewModel.categoryList[indexPath.row].category ?? ""
                cell.categoryLabel.text = category.capitalized

                // Get image name from ViewModel based on category name
                let imageName = homeViewModel.getCategoryImageName(for: category)
                cell.categoryImageView.image = UIImage(named: imageName)  // Set image from assets

                return cell
                
            case productCollectionView:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.CollectionViews.bottomCollectionViewNibNameAndIdentifier, for: indexPath) as! ProductsCollectionViewCell
                let product = homeViewModel.productList[indexPath.row]
                cell.productNameLabel.text = product.title
                cell.productRateLabel.text = "★ \(product.rate ?? 0)"
                cell.productPriceLabe.text = "$\(product.price ?? 0.0)"
                
                if let imageUrl = product.image, let url = URL(string: imageUrl) {
                    cell.loadImage(from: url)
                } else {
                    cell.productImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
                }

                return cell
                
            default:
                return UICollectionViewCell()
            }
        }
    }

    extension HomeViewController: UICollectionViewDelegate {
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("Selected indexPath: \(indexPath)")
            switch collectionView {
            case categoryCollectionView:
                guard indexPath.row < homeViewModel.categoryList.count else {
                    print("Index out of range for category collection view")
                    return
                }
                let category = homeViewModel.categoryList[indexPath.row].category
                changeVCcategoryToTableView(category: category ?? "")
            case productCollectionView:
                guard indexPath.row < homeViewModel.productList.count else {
                    print("Index out of range for product collection view")
                    return
                }
                let productId = homeViewModel.productList[indexPath.row].id
                changeVCHomeToProductDetail(id: productId ?? 0)
            default:
                print("Error at didSelectItemAt")
            }
        }
    }

