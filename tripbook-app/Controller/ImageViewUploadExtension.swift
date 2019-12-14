//
//  ImageViewUploadExtension.swift
//  tripbook-app
//
//  Created by Max Kornyev on 12/13/19.
//  Copyright © 2019 67442. All rights reserved.
//

import TinyConstraints
import FirebaseStorage
import FirebaseFirestore
import Kingfisher
import CoreLocation

extension ImageViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        imageView.image = selectedImage
        imagePickerController.dismiss(animated: true, completion: { () -> Void in
          // With a slight delay
          UIView.animate(withDuration: 2.0) {
            self.imageView.alpha = 0.0
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.renderPostForm()
          }
          // Additional Posting Options
//          let alert = UIAlertController(title: "Nice photo", message: "Would you like to post your image?", preferredStyle: .alert)
//
//          alert.addAction(UIAlertAction(title: "Yes please!", style: .default, handler: { (alert: UIAlertAction!) in
//            self.renderPostForm()
//          }))
//          alert.addAction(UIAlertAction(title: "Nope, not yet", style: .default, handler: { (alert: UIAlertAction!) in
//            self.renderUploadButton()
//          }))
//
//          self.present(alert, animated: true, completion: nil)
        })
    }
  
    func uploadPhotoHelper() {
      activityIndicator.startAnimating()
      
      guard let image = imageView.image,
          let data = image.jpegData(compressionQuality: 1.0) else {
          presentAlert(title: "Error", message: "Could not upoad photo.")
          return
      }
      
      let imageName = UUID().uuidString
      
      let imageReference = Storage.storage().reference()
          .child(DefaultKeys.imagesFolder)
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
            
              // Update trip images / image_coordinates for current user
              let userRef = Firestore.firestore().collection("users").document(DefaultKeys.userRefString)
            
              Firestore.firestore().collection("trips").whereField("user", isEqualTo: userRef).getDocuments() { (querySnapshot, err) in
                if err != nil { self.presentAlert(title: "Error", message: "Couldn't add image to Trip"); return; }
                let document = querySnapshot!.documents.first
                let geoPoint:GeoPoint = GeoPoint(latitude: self.lastRecordedLocation.latitude, longitude: self.lastRecordedLocation.longitude)
                
                document!.reference.updateData([
                  "images": FieldValue.arrayUnion([url.absoluteString]),
                  "image_coordinates": FieldValue.arrayUnion([geoPoint])
                ])
                
                // Save imageUrl
                self.imageUrl = url.absoluteString
                
                // POST UPLOAD
                
                let userRef = Firestore.firestore().collection("users").document(DefaultKeys.userRefString)
                let tripRef = Firestore.firestore().collection("trips").document(self.tripRefString)
                
                let data: [String: Any] = [
                    "comments_count": 0,
                    "date": Timestamp(date: Date()),
                    "is_liked": false,
                    "likes_count": 0,
                    "post_annotation": self.annotationText.text ?? "",
                    "post_image": self.imageUrl,
                    "tagline": self.summaryText.text ?? "",
                    "trip": tripRef,
                    "user": userRef
                ]

                Firestore.firestore().collection(DefaultKeys.postsCollection).addDocument(data: data) { err in
                  if err != nil {
                      self.presentAlert(title: "Error", message: "Could not upload post")
                    } else {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
              }
          })
      }
    }
}

