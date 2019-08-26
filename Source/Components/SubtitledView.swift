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
    label.font = .systemFont(ofSize: 10)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
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
    addSubview(imageView)
    addSubview(label)
  }
  
  func makeConstraints() {
    imageView.topAnchor.constraint(equalTo: topAnchor, constant: 8.0).isActive = true
    imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8.0).isActive = true
    imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8.0).isActive = true
    
    label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4.0).isActive = true
    label.leftAnchor.constraint(equalTo: leftAnchor, constant: 8.0).isActive = true
    label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.0).isActive = true
    label.rightAnchor.constraint(equalTo: rightAnchor, constant: -8.0).isActive = true
  }
}
