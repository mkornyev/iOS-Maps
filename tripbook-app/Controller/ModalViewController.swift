//
//  ModalViewController.swift
//  tripbook-app
//
//  Created by Max Kornyev on 11/8/19.
//  Copyright © 2019 67442. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
  
  var modalView: ModalView!
  var titleLabel: UILabel!

    override func viewDidLoad() {
      super.viewDidLoad()
      self.view.backgroundColor = .lightGray
      
      self.modalView = ModalView(frame: UIScreen.main.bounds)
      self.view.addSubview(self.modalView)
//      modalView = UIView()
//      modalView.backgroundColor = .red
//      self.view.addSubview(modalView)
//
//      titleLabel = UILabel()
//      titleLabel.text = "Post your trip"
//      titleLabel.textAlignment = .left
//      titleLabel.font = UIFont(name: "Helvetica Neue", size: 35)
//      modalView.addSubview(titleLabel)
//
//      // Set position of views using constraints
//      modalView.translatesAutoresizingMaskIntoConstraints = false
//      modalView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//      modalView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//      modalView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
//      modalView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1).isActive = true
//
//      titleLabel.translatesAutoresizingMaskIntoConstraints = false
//      titleLabel.topAnchor.constraint(equalTo: modalView.topAnchor).isActive = true
//      titleLabel.bottomAnchor.constraint(equalTo: modalView.bottomAnchor).isActive = true
//      titleLabel.widthAnchor.constraint(equalTo: modalView.widthAnchor).isActive = true
//      titleLabel.heightAnchor.constraint(equalTo: modalView.heightAnchor, multiplier: 0.5).isActive = true)
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
    contentStack.addArrangedSubview(headingLabel)
    contentStack.addArrangedSubview(annotationLabel)
    contentStack.addArrangedSubview(summaryLabel)
    contentStack.addArrangedSubview(centerStack)
    centerStack.addArrangedSubview(postButton)
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
  
  let headingLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFont(ofSize: 35)
    label.text = "Post your trip"
    return label
  }()
  
  let annotationLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFont(ofSize: 18)
    label.text = "Enter a heading for your post:"
    return label
  }()
  
  let summaryLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFont(ofSize: 18)
    label.text = "Enter a summary:"
    return label
  }()
  
  let postButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Post", for: .normal)
    return button
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
