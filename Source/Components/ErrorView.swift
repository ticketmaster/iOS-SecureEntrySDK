//
//  ErrorView.swift
//  SecureEntryView
//
//  Created by Vladislav Grigoryev on 05/07/2019.
//  Copyright © 2019 Ticketmaster. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import UIKit

final class ErrorView: UIView {
  
  lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [imageView, label])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .center
    stackView.axis = .vertical
    stackView.spacing = 8.0
    return stackView
  }()
  
  let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.isAccessibilityElement = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.image = .alert
    
    imageView.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
    imageView.setContentHuggingPriority(.defaultLow + 1, for: .vertical)

    imageView.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
    imageView.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
    
    return imageView
  }()
  
  let label: UILabel = {
    let label = UILabel()
    label.numberOfLines = 3
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Reload ticket"
    label.textColor = .darkGray
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 12.0)
    return label
  }()
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: 200.0, height: 110.0)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupView()
  }
  
  func setupView() {
    backgroundColor = .white
    layer.cornerRadius = 4.0
    
    addSubviews()
    makeConstraints()
  }
  
  func addSubviews() {
    addSubview(stackView)
  }
  
  func makeConstraints() {
    setContentHuggingPriority(.defaultHigh + 2, for: .vertical)
    setContentHuggingPriority(.defaultHigh + 2, for: .horizontal)
    
    setContentCompressionResistancePriority(.required, for: .horizontal)
    setContentCompressionResistancePriority(.required, for: .vertical)
    
    stackView.topAnchor.constraint(
      greaterThanOrEqualTo: topAnchor,
      constant: 10.0
    ).isActive = true
    stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10.0).isActive = true
    stackView.bottomAnchor.constraint(
      lessThanOrEqualTo: bottomAnchor,
      constant: -10.0
    ).isActive = true
    stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10.0).isActive = true
    stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
  }
}
