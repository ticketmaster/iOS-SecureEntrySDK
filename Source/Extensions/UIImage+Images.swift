//
//  UIImage.swift
//  SecureEntryView
//
//  Created by Vladislav Grigoryev on 08/07/2019.
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

// MARK: - Images
extension UIImage {
  
  private static let bundle = Bundle(for: SecureEntryView.self)

  static var alert: UIImage { return UIImage(named: "Alert", in: bundle, compatibleWith: nil)! }
}

// MARK: - Loading image
extension UIImage {
  
  private static weak var loadingImage: UIImage?

  private static var loadingImageCompletion: ((UIImage) -> Void)?
  
  static func getLoading(_ completion: @escaping (UIImage) -> Void) {
    if let loadingImage = loadingImage {
      completion(loadingImage)
      return
    }
    
    if let existingCompletion = loadingImageCompletion {
      loadingImageCompletion = {
        existingCompletion($0)
        completion($0)
      }
      return
    }
    
    loadingImageCompletion = completion
    
    DispatchQueue.global().async {
      guard let data = NSDataAsset(name: "Loading-crop", bundle: bundle)?.data else { return }
      guard let image = gif(data: data) else { return }
      
      DispatchQueue.main.async {
        loadingImage = image
        loadingImageCompletion?(image)
        loadingImageCompletion = nil
      }
    }
  }
}
