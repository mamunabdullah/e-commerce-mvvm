//
//  ProfileViewController.swift
//  LeadsE-Commerce
//
//  Created by Abdullah Al-Mamun on 5/9/24.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var profileUsernameLabel: UILabel!
    @IBOutlet weak var profileUserEmailLabel: UILabel!
    
    private let imagePicker = UIImagePickerController()
        private var viewModel: ProfileViewModel!
        
        //MARK: - Life cycle
        override func viewDidLoad() {
            super.viewDidLoad()
            viewModel = ProfileViewModel()
            bindViewModel()
            profilePictureSetup()
            viewModel.loadProfileImage()
        }
        
        //MARK: - Interaction handlers
        @IBAction func uploadProfilePhotoButtonPressed(_ sender: UIButton) {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
        
        @IBAction func signOutButtonPressed(_ sender: UIButton) {
            viewModel.signOut()
        }
        
        //MARK: - Functions
        func bindViewModel() {
            viewModel.onProfileImageLoaded = { [weak self] image in
                self?.profilePictureImageView.image = image
            }
            
            viewModel.onProfileImageSaved = {
                DuplicateFuncs.alertMessage(title: "Success", message: "Profile image saved.", vc: self)
            }
            
            viewModel.onSignOut = {
                // Handle sign out logic here, if needed
                // DuplicateFuncs.alertMessageWithHandler(...)
            }
        }
        
        func profilePictureSetup() {
            imagePicker.delegate = self
            profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.height / 2
            profilePictureImageView.layer.masksToBounds = true
        }
    }

    //MARK: - Extensions
    extension ProfileViewController: UIImagePickerControllerDelegate {
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                viewModel.selectedImage = pickedImage
                profilePictureImageView.image = pickedImage
                dismiss(animated: true)
                viewModel.saveProfileImage(pickedImage)
            }
        }
    }

    extension ProfileViewController: UINavigationControllerDelegate {
        // Do not remove this
    }
