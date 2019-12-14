//
//  ImageViewController.swift
//  tripbook-app
//
//  Created by Max Kornyev on 12/5/19.
//  Copyright © 2019 67442. All rights reserved.
//
//  Huge thanks to @Rebeloper on Youtube for help with this class
//

import TinyConstraints
import FirebaseStorage
import FirebaseFirestore
import Kingfisher
import CoreLocation


class ImageViewController: UIViewController {
    
  // MARK: - Image Vars

  let lastRecordedLocation: CLLocationCoordinate2D
  var imagePicker = UIImagePickerController()
  var imageUrl: String = ""
  var tripRefString: String = ""
  let defaultKeys: DefaultKeys = DefaultKeys()
  
  lazy var imagePickerController: UIImagePickerController = {
      let controller = UIImagePickerController()
      controller.delegate = self
      controller.sourceType = .camera
      return controller
  }()
  
  lazy var imageView: UIImageView = {
      let iv = UIImageView()
      iv.contentMode = .scaleAspectFit
      iv.clipsToBounds = true
      iv.backgroundColor = .gray
      return iv
  }()
  
  let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)

  // MARK: - Buttons and Form Vars
  lazy var takePhotoBarButton = UIBarButtonItem(title: "Take a Photo", style: .done, target: self, action: #selector(takePhoto))
  lazy var selectPhotoBarButton = UIBarButtonItem(title: "Select a Photo", style: .plain, target: self, action: #selector(selectPhoto))
  lazy var cancelBarButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelPhoto))

  lazy var scrollView: UIScrollView = {
     let view = UIScrollView()
    
      view.translatesAutoresizingMaskIntoConstraints = false
      view.contentSize.height = 2000
      
      return view
  }()

  lazy var contentStack: UIStackView = {
    let stackView = UIStackView(frame:.zero)
    
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.spacing = 10
    stackView.backgroundColor = .systemRed
    
    return stackView
  }()

  lazy var headingLabel: UILabel = {
      let label = UILabel()
      label.font = UIFont.systemFont(ofSize: 25)
      label.text = "Share your photo"
      label.textColor = .black
      label.textAlignment = .center
      label.layer.shadowOffset = CGSize(width: 2, height: 2)
      label.layer.shadowColor = UIColor.gray.cgColor
      label.layer.shadowOpacity = 0.5
      return label
    }()

  lazy var annotationLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18)
    label.text = "Enter a heading for your post:"
    label.textColor = .black
    return label
  }()
  
  lazy var annotationText: UITextField =  {
    let field = UITextField()
  
    field.placeholder = "A catchy caption"
    field.font = UIFont.systemFont(ofSize: 15)
    field.textColor = UIColor.blue
    field.backgroundColor = UIColor.white
    
    field.borderStyle = UITextField.BorderStyle.roundedRect
    field.autocorrectionType = UITextAutocorrectionType.no
    field.keyboardType = UIKeyboardType.default
    field.returnKeyType = UIReturnKeyType.done
    field.clearButtonMode = UITextField.ViewMode.whileEditing
    field.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
    
    return field
  }()
  
  let summaryLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18)
    label.text = "Enter a summary:"
    label.textColor = .black
    return label
  }()

  lazy var summaryText: UITextField =  {
    let field = UITextField()
  
    field.placeholder = "A scintillating summary"
    field.font = UIFont.systemFont(ofSize: 15)
    field.textColor = UIColor.blue
    field.backgroundColor = UIColor.white
    
    field.borderStyle = UITextField.BorderStyle.roundedRect
    field.autocorrectionType = UITextAutocorrectionType.no
    field.keyboardType = UIKeyboardType.default
    field.returnKeyType = UIReturnKeyType.done
    field.clearButtonMode = UITextField.ViewMode.whileEditing
    field.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
    
    return field
  }()
  
  // MARK: - Inits
  init(location: CLLocationCoordinate2D, tripRefString: String) {
    self.lastRecordedLocation = location
    self.tripRefString = tripRefString
    super.init(nibName: nil, bundle: nil) // Must come last
  }

  required init?(coder: NSCoder) {
    fatalError("Failed to init tripData")
  }
  
  // MARK: - Methods

  override func viewDidLoad() {
      super.viewDidLoad()

      renderScrollView()
      navigationItem.setLeftBarButtonItems([takePhotoBarButton, selectPhotoBarButton], animated: true)
      navigationItem.setRightBarButtonItems([cancelBarButton], animated: true)
    
      view.backgroundColor = .white

      imageView.edgesToSuperview()
      activityIndicator.centerInSuperview()
      
  }

  func renderScrollView() {
    view.addSubview(scrollView)
    
    scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(imageView)
    
    imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
    imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40).isActive = true
    
    imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 20).isActive = true
    imageView.widthAnchor.constraint(equalToConstant: (view.frame.width*3)/5).isActive = true
    imageView.heightAnchor.constraint(equalToConstant: 500).isActive = true
    
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(contentStack)
    
    contentStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
    
    contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
    contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    contentStack.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
    contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    
    // Add activity indicator
    scrollView.addSubview(activityIndicator)
    activityIndicator.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
  }
  
  func renderPostForm() {
    contentStack.addArrangedSubview(headingLabel)
    
    headingLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
    headingLabel.topAnchor.constraint(equalTo: contentStack.topAnchor, constant: 0).isActive = true
    headingLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20).isActive = true
    
    contentStack.addArrangedSubview(annotationLabel)
    
    annotationLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
    annotationLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 40).isActive = true
    annotationLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20).isActive = true
    
    contentStack.addArrangedSubview(annotationText)
    
    annotationText.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
    annotationText.topAnchor.constraint(equalTo: annotationLabel.bottomAnchor, constant: 20).isActive = true
    annotationText.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20).isActive = true
    
    contentStack.addArrangedSubview(summaryLabel)
    
    summaryLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
    summaryLabel.topAnchor.constraint(equalTo: annotationText.bottomAnchor, constant: 40).isActive = true
    summaryLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20).isActive = true
    
    contentStack.addArrangedSubview(summaryText)
    
    summaryText.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
    summaryText.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 20).isActive = true
    summaryText.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20).isActive = true
    
    let postButton = UIButton()
    
    postButton.setTitle("Post my photo", for: .normal)
    postButton.addTarget(self, action: #selector(uploadPost), for: .touchUpInside)
    
    postButton.backgroundColor = .blue
    postButton.alpha = 0.85
    postButton.setTitleColor(.white, for: .normal)
    postButton.setTitleColor(.darkGray, for: .highlighted)
    postButton.setTitleShadowColor(.systemGray, for: .normal)
    postButton.layer.cornerRadius = 10
    postButton.layer.borderWidth = 0.2
    postButton.layer.borderColor = UIColor.white.cgColor
    
    contentStack.addArrangedSubview(postButton)
    
    postButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
    postButton.topAnchor.constraint(equalTo: summaryText.bottomAnchor, constant: 40).isActive = true
    postButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20).isActive = true
    postButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
  }
  
  func renderUploadButton() {
    let postButton = UIButton()
    
    postButton.setTitle("Add photo to trip", for: .normal)
    postButton.addTarget(self, action: #selector(uploadPhoto), for: .touchUpInside)
    
    postButton.backgroundColor = .blue
    postButton.alpha = 0.85
    postButton.setTitleColor(.white, for: .normal)
    postButton.setTitleColor(.darkGray, for: .highlighted)
    postButton.setTitleShadowColor(.systemGray, for: .normal)
    postButton.layer.cornerRadius = 10
    postButton.layer.borderWidth = 0.2
    postButton.layer.borderColor = UIColor.white.cgColor
    
    contentStack.addArrangedSubview(postButton)
    
    postButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
    postButton.topAnchor.constraint(equalTo: contentStack.topAnchor, constant: 40).isActive = true
    postButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20).isActive = true
    postButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
  }
        
    
  @objc fileprivate func takePhoto() {
      present(imagePickerController, animated: true, completion: nil)
  }
  
  @objc fileprivate func cancelPhoto() {
      self.navigationController?.popToRootViewController(animated: true)
  }
    
    
  @objc fileprivate func uploadPhoto() {
        uploadPhotoHelper()
        self.navigationController?.popToRootViewController(animated: true)
  }
  
  @objc func selectPhoto() {
    if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
        imagePicker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false

        present(imagePicker, animated: true, completion: nil)
    }
  }
  
  @objc func uploadPost() {
    if summaryText.text == "" || annotationText.text == "" {
      presentAlert(title: "Error", message: "Fill out all the fields")
      return
    }
    
    // Save photo to FireStorage
    uploadPhotoHelper()
  }
    
  func presentAlert(title: String, message: String) {
      activityIndicator.stopAnimating()
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
  }
}
