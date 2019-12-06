//
//  ImageViewController.swift
//  tripbook-app
//
//  Created by Max Kornyev on 12/5/19.
//  Copyright © 2019 67442. All rights reserved.
//

import TinyConstraints
import FirebaseStorage
import FirebaseFirestore
import Kingfisher

struct MyKeys {
    static let imagesFolder = "userImages"
    static let imagesCollection = "posts"
    static let uid = "uid"
    static let imageUrl = "imageUrl"
}

class ImageViewController: UIViewController {
  
    let userRefString = "jTwrnfSpEiOFVmnYyFtg" // WILL ADD A PLIST VAL FOR THIS
    
    lazy var takePhotoBarButton = UIBarButtonItem(title: "Take a Photo", style: .done, target: self, action: #selector(takePhoto))
    lazy var selectPhotoBarButton = UIBarButtonItem(title: "Select a Photo", style: .plain, target: self, action: #selector(selectPhoto))
    var uploadPhotoButton = UIButton(frame: CGRect(x: 75, y: 600, width: 85, height: 35))
  
    var imagePicker = UIImagePickerController()
    
    lazy var imagePickerController: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .camera
        return controller
    }()
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .white
        return iv
    }()
    
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.setLeftBarButtonItems([takePhotoBarButton, selectPhotoBarButton], animated: true)
      
      // add button to screen later
      
        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(activityIndicator)
        imageView.edgesToSuperview()
        activityIndicator.centerInSuperview()
        
        setButtonStyle()
    }
  
    func setButtonStyle() {
      uploadPhotoButton.setTitle("Add Photo to Trip", for: .normal)
      uploadPhotoButton.addTarget(self, action: #selector(uploadPhoto), for: .touchUpInside)
      
      uploadPhotoButton.backgroundColor = .blue
      uploadPhotoButton.alpha = 0.85
      uploadPhotoButton.setTitleColor(.white, for: .normal)
      uploadPhotoButton.setTitleColor(.darkGray, for: .highlighted)
      uploadPhotoButton.setTitleShadowColor(.systemGray, for: .normal)
      uploadPhotoButton.layer.cornerRadius = 10
      uploadPhotoButton.layer.borderWidth = 0.2
      uploadPhotoButton.layer.borderColor = UIColor.white.cgColor
    }
        
    
    @objc fileprivate func takePhoto() {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    @objc fileprivate func uploadPhoto() {
        activityIndicator.startAnimating()
        
        guard let image = imageView.image,
            let data = image.jpegData(compressionQuality: 1.0) else {
            presentAlert(title: "Error", message: "Could not upoad photo.")
            return
        }
        
        let imageName = UUID().uuidString
        
        let imageReference = Storage.storage().reference()
            .child(MyKeys.imagesFolder)
            .child(imageName)
        
        imageReference.putData(data, metadata: nil) { (metadata, err) in
            if let err = err {
                self.presentAlert(title: "Error", message: err.localizedDescription)
                return
            }
            
            imageReference.downloadURL(completion: { (url, err) in
                if let err = err {
                    self.presentAlert(title: "Error", message: err.localizedDescription)
                    return
                }
                
                guard let url = url else {
                    self.presentAlert(title: "Error", message: "Something went wrong")
                    return
                }
              
                // Update trip for current user
                let userRef = Firestore.firestore().collection("users").document(self.userRefString)
              
                Firestore.firestore().collection("trips").whereField("user", isEqualTo: userRef).getDocuments() { (querySnapshot, err) in
                  if let err = err { self.presentAlert(title: "Error", message: "Couldn't add image to Trip") }
                  else {
                      let document = querySnapshot!.documents.first
                      document!.reference.updateData([
                        "images": FieldValue.arrayUnion([url.absoluteString])
                      ])
                  }
                }
            })
        }
    }
  
  
  
  //                // Build a new document ref
  //                let dataReference = Firestore.firestore().collection(MyKeys.imagesCollection).document()
  //                let documentUid = dataReference.documentID
  //
  //                let urlString = url.absoluteString
  //
  //                let data = [
  //                    MyKeys.uid: documentUid,
  //                    MyKeys.imageUrl: urlString
  //                ]
  //
  //                // UPLOAD the actual photo
  //                dataReference.setData(data, completion: { (err) in
  //                    if let err = err {
  //                        self.presentAlert(title: "Error", message: err.localizedDescription)
  //                        return
  //                    }
  //
  //                    UserDefaults.standard.set(documentUid, forKey: MyKeys.uid)
  //                    self.imageView.image = UIImage()
  //                    self.presentAlert(title: "Success", message: "Successfully save image to database")
  //                })
  
  @objc func selectPhoto() {
    if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
        imagePicker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false

        present(imagePicker, animated: true, completion: nil)
    }
  }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError err: Error?, contextInfo: UnsafeRawPointer) {
        activityIndicator.stopAnimating()
        if let err = err {
            // we got back an error!
            presentAlert(title: "Error", message: err.localizedDescription)
        } else {
            presentAlert(title: "Saved!", message: "Image saved successfully")
        }
    }
    
    func presentAlert(title: String, message: String) {
        activityIndicator.stopAnimating()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}

extension ImageViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        imageView.image = selectedImage
        imagePickerController.dismiss(animated: true, completion: nil)
        self.view.addSubview(uploadPhotoButton) // Upload only once image picked
    }
}

