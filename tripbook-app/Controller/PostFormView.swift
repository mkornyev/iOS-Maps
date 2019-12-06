//
//  ModalViewController.swift
//  tripbook-app
//
//  Created by Max Kornyev on 11/8/19.
//  Copyright © 2019 67442. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class PostFormView: UIViewController {
  
  // MARK: UIElements
  
  var modalView: ModalView!
  
  lazy var contentStack: UIStackView = {
     let stackView = UIStackView(frame:.zero)
     
     stackView.axis = .vertical
     stackView.distribution = .equalSpacing
     stackView.spacing = 10
     
     return stackView
   }()
  
  lazy var headingLabel: UILabel = {
//    let label = UILabel(frame: .zero)
    let label = UILabel(frame: CGRect(x: 0, y: 100, width: view.frame.size.width, height: 100))
    label.font = UIFont.systemFont(ofSize: 35)
    label.text = "Post your trip"
    label.textColor = .white
    label.textAlignment = .center
    label.layer.shadowOffset = CGSize(width: 2, height: 2)
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowOpacity = 0.5
    return label
  }()
  
  lazy var annotationLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFont(ofSize: 18)
    label.text = "Enter a heading for your post:"
    label.textColor = .white
    return label
  }()
  
  lazy var annotationText: UITextField =  {
    let field = UITextField(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
  
    field.placeholder = "A catchy caption!"
    field.font = UIFont.systemFont(ofSize: 15)
    field.textColor = UIColor.blue
    field.backgroundColor = UIColor.white
    
    field.borderStyle = UITextField.BorderStyle.roundedRect
    field.autocorrectionType = UITextAutocorrectionType.no
    field.keyboardType = UIKeyboardType.default
    field.returnKeyType = UIReturnKeyType.done
    field.clearButtonMode = UITextField.ViewMode.whileEditing
    field.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
//    field.delegate = self
    
    return field
  }()
  
  let summaryLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFont(ofSize: 18)
    label.text = "Enter a summary:"
    label.textColor = .white
    return label
  }()
  
  let postButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Post", for: .normal)
    button.setTitleColor(.blue, for: .normal)
    button.setTitleColor(.systemBlue, for: .selected)
    return button
  }()
  
  // MARK: - INIT
  
//  init(tripData: TripData) {
//    self.tripData = tripData
//  }
//
//  required init?(coder: NSCoder) {
//    fatalError("Failed to init? ModalVC")
//  }

  // MARK: - Methods
  
    override func viewDidLoad() {
      super.viewDidLoad()
      self.view.backgroundColor = .lightGray
      
//      tripData.end_date = Date()
      
      let currentTime = Date()
      let annotation = self.annotationText.text ?? ""
      
//      postButton.addTarget(self, action: { button in
//        createPost(id: tripData.user, date: currentTime, post_annotation: annotation, trip: "JCzEKCv9XGglmZyq8V0J", user: tripData.user, post_images: [])
//      }, for: .touchUpInside)
      
//      self.view.addSubview(contentStack)
      
//      contentStack.addArrangedSubview(headingLabel)
      self.view.addSubview(headingLabel)
      
//      contentStack.addArrangedSubview(annotationLabel)
      self.view.addSubview(annotationLabel)
//      contentStack.addArrangedSubview(annotationText)
      self.view.addSubview(annotationText)
      
//      contentStack.addArrangedSubview(summaryLabel)
      self.view.addSubview(summaryLabel)
      
//      contentStack.addArrangedSubview(postButton)
      self.view.addSubview(postButton)
      
//      self.modalView = ModalView(frame: UIScreen.main.bounds)
//      self.view.addSubview(self.modalView)
      
//      modalView = UIView()
//      modalView.backgroundColor = .red
//      self.view.addSubview(modalView)
    }
  
//  override func loadView() {
//    self.modalView = ModalView(frame: UIScreen.main.bounds)
//  }

}

class ModalView: UIView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("Failed to init? tripData")
  }
  
  func setupViews() {
    self.addSubview(contentStack)
//    self.addSubview(headingLabel)
//    contentStack.addArrangedSubview(headingLabel)
//    contentStack.addArrangedSubview(annotationLabel)
//    contentStack.addArrangedSubview(summaryLabel)
    contentStack.addArrangedSubview(centerStack)
//    centerStack.addArrangedSubview(postButton)
//    contentStack.addArrangedSubview()
  }
  
  func setupConstraints() {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
    self.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
    self.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    self.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
  }
    
  let contentStack: UIStackView = {
    let stackView = UIStackView(frame:.zero)
    
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.spacing = 10
    
    return stackView
  }()
  
  let centerStack: UIStackView = {
    let stackView = UIStackView(frame:.zero)
    
    stackView.axis = .horizontal
    stackView.distribution = .equalSpacing
    stackView.spacing = 0
    
    return stackView
  }()

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
