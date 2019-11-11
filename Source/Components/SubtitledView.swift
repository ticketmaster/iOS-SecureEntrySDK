//
//  SubtitledView.swift
//  SecureEntryView
//
//  Created by Vladislav Grigoryev on 10/07/2019.
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

final class SubtitledView: UIView {
  
  lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [imageView, label])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.spacing = 12.0
    return stackView
  }()
  
  let imageView: RatioImageView = {
    let imageView = RatioImageView()
    imageView.isAccessibilityElement = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.layer.magnificationFilter = .nearest
    return imageView
  }()
  
  let label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
    label.textColor = .mineShaft
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  lazy var topContentConstraint: NSLayoutConstraint = stackView.topAnchor.constraint(
    equalTo: topAnchor, constant: contentInsets.top
  )
  
  lazy var leftContentConstraint: NSLayoutConstraint = stackView.leftAnchor.constraint(
    equalTo: leftAnchor, constant: contentInsets.left
  )
  
  lazy var bottomContentConstraint: NSLayoutConstraint = stackView.bottomAnchor.constraint(
    equalTo: bottomAnchor, constant: -contentInsets.bottom
  )
  
  lazy var rightContentConstraint: NSLayoutConstraint = stackView.rightAnchor.constraint(
    equalTo: rightAnchor, constant: -contentInsets.right
  )
  
  var contentInsets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0) {
    didSet {
      stackView.spacing = contentInsets.bottom

      topContentConstraint.constant = contentInsets.top
      leftContentConstraint.constant = contentInsets.left
      bottomContentConstraint.constant = -contentInsets.bottom
      rightContentConstraint.constant = -contentInsets.right
    }
  }

  init() {
    super.init(frame: .zero)
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
    topContentConstraint.isActive = true
    leftContentConstraint.isActive = true
    bottomContentConstraint.isActive = true
    rightContentConstraint.isActive = true
  }
}
