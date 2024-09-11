//
//  CartViewController.swift
//  LeadsE-Commerce
//
//  Created by Abdullah Al-Mamun on 5/9/24.
//

import UIKit

class CartViewController: UIViewController {

    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyCartView: UIView!
    
    private var viewModel: CartViewModel!

        //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = CartViewModel()
        bindViewModel()
        
        tableViewSetup()
        viewModel.loadCartItems()
        
        // Observe cart update notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleCartUpdateNotification), name: .cartUpdated, object: nil)
    }
    
    @objc func handleCartUpdateNotification() {
        viewModel.loadCartItems()
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .cartUpdated, object: nil)
    }

        //MARK: - Interaction handlers
        @IBAction func checkoutButtonPressed(_ sender: UIButton) {
            viewModel.handleCheckout()
        }

        //MARK: - Functions
        func tableViewSetup() {
            tableView.register(UINib(nibName: K.TableView.cartTableViewCell, bundle: nil), forCellReuseIdentifier: K.TableView.cartTableViewCell)
            tableView.dataSource = self
            tableView.delegate = self
        }
        
        func bindViewModel() {
            viewModel.onCartUpdated = { [weak self] in
                self?.tableView.reloadData()
            }
            viewModel.onTotalPriceUpdated = { [weak self] totalPrice in
                self?.totalPriceLabel.text = totalPrice
            }
            viewModel.onCartBadgeUpdated = { [weak self] count in
                self?.updateCartBadge(count: count)
            }
            viewModel.onEmptyCartViewUpdated = { [weak self] isEmpty in
                self?.emptyCartView.isHidden = !isEmpty
            }
            viewModel.onAlertMessage = { [weak self] title, message in
                DuplicateFuncs.alertMessage(title: title, message: message, vc: self!)
            }
        }
        
        func updateCartBadge(count: Int) {
            if let tabBarController = self.tabBarController {
                if let tabBarItem = tabBarController.tabBar.items?[1] {
                    tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
                }
            }
        }
    }

    // MARK: - Extensions
    extension CartViewController: UITableViewDataSource, UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return viewModel.cartItems.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.TableView.cartTableViewCell, for: indexPath) as! CartTableViewCell
            let product = viewModel.cartItems[indexPath.row]
            
            if let imageUrl = product.image, let url = URL(string: imageUrl) {
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data, error == nil {
                        DispatchQueue.main.async {
                            cell.productImageView.image = UIImage(data: data)
                        }
                    }
                }
                task.resume()
            } else {
                cell.productImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
            }
            
            cell.productPriceLabel.text = "$\(product.price ?? -1)"
            cell.productTitleLabel.text = product.title
            cell.productQuantity.text = "\(product.quantityCount ?? 0)"
            
            cell.plusButton.tag = indexPath.row
            cell.plusButton.addTarget(self, action: #selector(plusButtonTapped(_:)), for: .touchUpInside)
            
            cell.minusButton.tag = indexPath.row
            cell.minusButton.addTarget(self, action: #selector(minusButtonTapped(_:)), for: .touchUpInside)
            
            //cell.deleteButton.tag = indexPath.row
           // cell.deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)

            return cell
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }

        @objc func plusButtonTapped(_ sender: UIButton) {
            let index = sender.tag
            viewModel.handlePlusButtonTapped(at: index)
        }

        @objc func minusButtonTapped(_ sender: UIButton) {
            let index = sender.tag
            viewModel.handleMinusButtonTapped(at: index)
        }

        @objc func deleteButtonTapped(_ sender: UIButton) {
            let index = sender.tag
            viewModel.handleDeleteItem(at: index)
        }
    }




