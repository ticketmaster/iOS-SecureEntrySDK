//
//  ScanAnimationView.swift
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

final class ScanAnimationView: UIView {

  let boxView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  let lineView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  override var tintColor: UIColor! {
    didSet {
      guard tintColor != oldValue else { return }
      updateColors()
    }
  }
  
  override var isHidden: Bool {
    didSet {
      guard isHidden != oldValue else { return }
      updateAnimation()
    }
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
  
  override func didMoveToWindow() {
    super.didMoveToWindow()
    updateAnimation()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    updateAnimation()
  }
  
  func setupView() {
    addSubviews()
    makeConstraints()
    updateColors()
    subscribeToNotifications()
  }
  
  func addSubviews() {
    addSubview(boxView)
    addSubview(lineView)
  }
  
  func makeConstraints() {
    boxView.widthAnchor.constraint(equalToConstant: 12.0).isActive = true
    boxView.topAnchor.constraint(equalTo: topAnchor, constant: 8.0).isActive = true
    boxView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0).isActive = true
    boxView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true

    lineView.widthAnchor.constraint(equalToConstant: 4.0).isActive = true
    lineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    lineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    lineView.centerXAnchor.constraint(equalTo: boxView.centerXAnchor).isActive = true
  }
  
  func subscribeToNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(stopAnimation),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(updateAnimation),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }
  
  func updateColors() {
    boxView.backgroundColor = tintColor.withAlphaComponent(0.5)
    lineView.backgroundColor = tintColor
  }
  
  @objc
  func updateAnimation() {
    if window != nil && !isHidden {
      startAnimation()
    }
    else {
      stopAnimation()
    }
  }
  
  func startAnimation() {
    let transform = CGAffineTransform(
      translationX: bounds.size.width - boxView.bounds.size.width,
      y: 0.0
    )
    
    UIView.animate(
      withDuration: 1.5,
      delay: 0.4,
      options: [.curveEaseInOut, .repeat, .autoreverse, .beginFromCurrentState],
      animations: { self.boxView.transform = transform },
      completion: nil
    )
    
    UIView.animate(
      withDuration: 1.5,
      delay: 0.3,
      options: [.curveEaseInOut, .repeat, .autoreverse, .beginFromCurrentState],
      animations: { self.lineView.transform = transform },
      completion: nil)
  }
  
  @objc
  func stopAnimation() {
    boxView.transform = .identity
    lineView.transform = .identity
    boxView.layer.removeAllAnimations()
    lineView.layer.removeAllAnimations()
  }
}
