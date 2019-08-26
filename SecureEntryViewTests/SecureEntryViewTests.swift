//
//  SecureEntryViewTests.swift
//  SecureEntryViewTests
//
//  Created by Karl White on 11/30/18.
//  Copyright © 2018 Ticketmaster. All rights reserved.
//

import XCTest
@testable import Presence

private final class SecureEntryViewTests: XCTestCase {
  
  private static let V3_ROTATING_TOKEN: String = "eyJiIjoiNDg2ODg2OTg3Nzc1MTAwOWEiLCJ0IjoiVE06OjAzOjo3dXhiOWxhZ3FjenNwc2RicGRqaDEwbjVhY3hzYzJyYnc2ZzB6cTBrbXVtOGRsY3A2IiwiY2siOiJlZTlmOWZjMDA0NjE0MjE5YzY5YmM5ZjA2MzAxOTlkY2I5YjY3N2JmIn0="
  private static let V3_QR_CODE_TOKEN: String = "eyJiIjoiNDg2ODg2OTg3Nzc1MTAwOWEifQ=="
  private static let V4_STATIC_PDF417_TOKEN: String = "eyJiIjoiODMwNTM2NjY1MTU4ayIsInJ0Ijoicm90YXRpbmdfc3ltYm9sb2d5In0="
  private static let V4_QR_CODE: String = "eyJiIjoiMDg2NzM0NjQ3NjA0MTYxNmEiLCJydCI6ImJhcmNvZGUifQ=="
  private static let V4_ROTATING_TOKEN: String = "eyJiIjoiODUwMDYxNTcwMjU3USIsInQiOiJCQUlBV0xGYml6dU9FUUFBQUFBQUFBQUFBQUNqdXh3dTlEZXpieFRQbktjOFRhVkxabFpPQ3pYYXh4YWtKMWdWIiwiY2siOiJkN2ZhMGEwZTc4NzJhYzVkNDY2MjhlMmY5YWZkMDExMWVjOGU4N2JmIiwiZWsiOiI5YTE2MDUwOTc3OWU2MDhhZGZlZTg0YmQyN2QwODc3YTVjY2U5MTY2IiwicnQiOiJyb3RhdGluZ19zeW1ib2xvZ3kifQ=="
  
  func test_init_withDefaultBrandingColor() {
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    let secureEntryView: SecureEntryView = SecureEntryView()
    XCTAssert(secureEntryView.brandingColor == .blue)
  }
  
  func test_setBrandingColor_Should_Set_BrandingColor() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    
    // when
    secureEntryView.brandingColor = .purple;
    
    // then
    XCTAssert(secureEntryView.brandingColor == UIColor.purple)
  }
  
  func test_setBarcodeSubtitle_Should_Set_BarcodeSubtitle() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    
    // when
    secureEntryView.pdf417Subtitle = "Screenshots are a no go!"
    secureEntryView.qrSubtitle = "Screenshots are a no go!"
    
    //then
    XCTAssert(secureEntryView.pdf417Subtitle == "Screenshots are a no go!")
    XCTAssert(secureEntryView.qrSubtitle == "Screenshots are a no go!")
  }
  
  func test_setBarcodeSubtitle_Blank_Should_Set_BarcodeSubtitleBlank() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    
    //when
    secureEntryView.pdf417Subtitle = ""
    secureEntryView.qrSubtitle = ""
    
    //then
    XCTAssert(secureEntryView.pdf417Subtitle.isEmpty)
    XCTAssert(secureEntryView.qrSubtitle.isEmpty)
  }
  
  func test_enableBrandingSubtitle_Should_Be_Colored() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    
    //when
    secureEntryView.brandingColor = .purple
    secureEntryView.isSubtitleBrandingEnabled = true
    
    //then
    XCTAssert(secureEntryView.barcodeView.label.textColor == .purple)
  }
  
  func test_enableBrandinSubtitle_False_Should_Be_Default_Color(){
    let secureEntryView: SecureEntryView = SecureEntryView()
    
    //when
    secureEntryView.brandingColor = .purple

    //then
    XCTAssert(secureEntryView.barcodeView.label.textColor == .mineShaft)
  }
  
  func test_setErrorMessage_Should_Show_ErrorMessage() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    
    // when
    secureEntryView.showError(message: "Custom error text")
    
    // then
    XCTAssert(secureEntryView.errorView.isHidden == false)
    XCTAssert(secureEntryView.errorView.label.text == "Custom error text")
  }
  
  func test_setToken_With_V3RotatingData_Should_Create_EntryData() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = SecureEntryViewTests.V3_ROTATING_TOKEN
    
    guard let entryData = secureEntryView.entryData, case .rotatingPDF417(
      let token,
      let customerKey,
      let eventKey,
      let barcode
    ) = entryData else {
      XCTFail("Wrong Entry Data Type")
      return
    }
    
    let customerKeyData = EntryData.encodeOTPSecretBytes("ee9f9fc004614219c69bc9f0630199dcb9b677bf")
    XCTAssert(token == "TM::03::7uxb9lagqczspsdbpdjh10n5acxsc2rbw6g0zq0kmum8dlcp6")
    XCTAssert(customerKey == customerKeyData)
    XCTAssert(eventKey == nil)
    XCTAssert(barcode == "4868869877751009a")
  }
  
  func test_setToken_With_V3QrData_Should_Create_EntryData() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = SecureEntryViewTests.V3_QR_CODE_TOKEN
    
    guard let entryData = secureEntryView.entryData, case .qrCode(let barcode) = entryData else {
      XCTFail("Wrong Entry Data Type")
      return
    }
    
    XCTAssert(barcode == "4868869877751009a")
  }
  
  func test_setToken_With_V4StaticPdfData_Should_Create_EntryData() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = SecureEntryViewTests.V4_STATIC_PDF417_TOKEN
    
    guard
      let entryData = secureEntryView.entryData,
      case .staticPDF417(let barcode) = entryData
    else {
      XCTFail("Wrong Entry Data Type")
      return
    }
    
    XCTAssert(barcode == "830536665158k")
  }
  
  func test_setToken_Wit_V4RotatingData_Should_Create_EntryData() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = SecureEntryViewTests.V4_ROTATING_TOKEN
    
    guard let entryData = secureEntryView.entryData, case .rotatingPDF417(
      let token,
      let customerKey,
      let eventKey,
      let barcode
    ) = entryData else {
      XCTFail("Wrong Entry Data Type")
      return
    }
    
    let customerKeyData = EntryData.encodeOTPSecretBytes("d7fa0a0e7872ac5d46628e2f9afd0111ec8e87bf")
    let eventKeyData = EntryData.encodeOTPSecretBytes("9a160509779e608adfee84bd27d0877a5cce9166")
    XCTAssert(token == "BAIAWLFbizuOEQAAAAAAAAAAAACjuxwu9DezbxTPnKc8TaVLZlZOCzXaxxakJ1gV")
    XCTAssert(customerKey == customerKeyData)
    XCTAssert(eventKey == eventKeyData)
    XCTAssert(barcode == "850061570257Q")
  }
  
  func test_setToken_With_V4QrCodeData_Should_Create_EntryData() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = SecureEntryViewTests.V4_QR_CODE
    
    guard let entryData = secureEntryView.entryData, case .qrCode(let barcode) = entryData else {
      XCTFail("Wrong Entry Data Type")
      return
    }
    
    XCTAssert(barcode == "0867346476041616a")
  }
  
  func test_generate_PdfBitmap_With_V3RotatingData_Should_Create_Pdf417Bitmap() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = SecureEntryViewTests.V3_ROTATING_TOKEN
    
    guard case .rotatingPDF417(_, _, let image, _, _, _) = secureEntryView.state else {
      XCTFail("Wrong State")
      return
    }
    
    XCTAssert(secureEntryView.barcodeView.imageView.image == image)
  }
  
  func test_generate_PdfBitmap_With_V4RotatingData_Should_Create_Pdf417Bitmap() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = SecureEntryViewTests.V4_ROTATING_TOKEN
    
    guard case .rotatingPDF417(_, _, let image, _, _, _) = secureEntryView.state else {
      XCTFail("Wrong State")
      return
    }
    
    XCTAssert(secureEntryView.barcodeView.imageView.image == image)
  }
  
  func test_generate_QrCodeBitmap_With_V3StaticData_Should_Create_QrCodeBitmap() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = SecureEntryViewTests.V3_QR_CODE_TOKEN
    
    guard case .qrCode(_, let image, _) = secureEntryView.state else {
      XCTFail("Wrong State")
      return
    }
    
    XCTAssert(secureEntryView.barcodeView.imageView.image == image)
  }
  
  func test_getNewOTP_With_V3RotatingData_Should_Create_Expected_MessageToEncode() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = SecureEntryViewTests.V3_ROTATING_TOKEN
    
    guard let entryData = secureEntryView.entryData, case .rotatingPDF417(
      let token,
      let customerKey,
      _,
      _
    ) = entryData else {
      XCTFail("Wrong Entry Data Type")
      return
    }
    
    guard case .rotatingPDF417(let value, _, _, _, _, _) = secureEntryView.state else {
      XCTFail("Wrong State")
      return
    }
    
    let totp = TOTP.shared
    let (customerNow, _) = totp.generate(secret: customerKey)
    
    let components = value.components(separatedBy: "::")
    XCTAssert(components.count == 4)
    XCTAssert(components[0..<3].joined(separator: "::") == token)
    XCTAssert(components[3] == customerNow)
  }
  
  func test_getNewOTP_With_V4RotatingData_Should_Create_Expected_MessageToEncode() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = SecureEntryViewTests.V4_ROTATING_TOKEN
    
    guard let entryData = secureEntryView.entryData, case .rotatingPDF417(
      let token,
      let customerKey,
      let eventKey,
      _
    ) = entryData else {
      XCTFail("Wrong Entry Data Type")
      return
    }
    
    guard case .rotatingPDF417(let value, _, _, _, _, _) = secureEntryView.state else {
      XCTFail("Wrong State")
      return
    }
    
    let totp = TOTP.shared
    let (customerNow, _) = totp.generate(secret: customerKey)
    let (eventNow, eventTimestamp) = totp.generate(secret: eventKey!)
    
    let components = value.components(separatedBy: "::")
    XCTAssert(components.count == 4)
    XCTAssert(components[0] == token)
    XCTAssert(components[1] == eventNow)
    XCTAssert(components[2] == customerNow)
    XCTAssert(components[3] == "\(eventTimestamp)")
  }
  
  func test_setToken_With_Null_Should_Have_Loading() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = nil

    XCTAssert(secureEntryView.entryData == nil)
    if case .none = secureEntryView.state { } else { XCTFail("Wrong State") }
  }
  
  func test_setToken_With_InvalidJson_Should_Have_DefaultErrorMessage() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = "Invalid JSON payload"
    
    guard case .error(let message, let icon) = secureEntryView.state else {
      XCTFail("Wrong State")
      return
    }

    XCTAssert(secureEntryView.errorMessage == "Reload ticket")
    
    XCTAssert(message == secureEntryView.errorMessage)
    XCTAssert(icon == .alert)
    
    if let entryData = secureEntryView.entryData,
       case .invalid = entryData { }
    else { XCTFail("Wrong Entry Data") }
    
    XCTAssert(secureEntryView.errorView.label.text == message)
    XCTAssert(secureEntryView.errorView.imageView.image == icon)
  }
  
  func test_setToken_With_12DigitBarcode_Should_Create_EntryData() {
    let token = "486886987775a"
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = token
    
    guard let entryData = secureEntryView.entryData, case .qrCode(let barcode) = entryData else {
      XCTFail("Wrong Entry Data Type")
      return
    }
    
    XCTAssert(barcode == token)
  }
  
  func test_setToken_With_13DigitBarcode_Should_Create_EntryData() {
    let token = "4868869877751a"
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = token
    
    guard let entryData = secureEntryView.entryData, case .qrCode(let barcode) = entryData else {
      XCTFail("Wrong Entry Data Type")
      return
    }
    
    XCTAssert(barcode == token)
  }
  
  func test_setToken_With_14DigitBarcode_Should_Create_EntryData() {
    let token = "48688698777510a"
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = token
    
    guard let entryData = secureEntryView.entryData, case .qrCode(let barcode) = entryData else {
      XCTFail("Wrong Entry Data Type")
      return
    }
    
    XCTAssert(barcode == token)
  }
  
  func test_setToken_With_15DigitBarcode_Should_Create_EntryData() {
    let token = "486886987775100a"
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = token
    
    guard let entryData = secureEntryView.entryData, case .qrCode(let barcode) = entryData else {
      XCTFail("Wrong Entry Data Type")
      return
    }
    
    XCTAssert(barcode == token)
  }
  
  func test_setToken_With_16DigitBarcode_Should_Create_EntryData() {
    let token = "4868869877751009a"
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = token
    
    guard let entryData = secureEntryView.entryData, case .qrCode(let barcode) = entryData else {
      XCTFail("Wrong Entry Data Type")
      return
    }
    
    XCTAssert(barcode == token)
  }
  
  func test_setToken_With_17DigitBarcode_Should_Create_EntryData() {
    let token = "48688698777510094a"
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = token
    
    guard let entryData = secureEntryView.entryData, case .qrCode(let barcode) = entryData else {
      XCTFail("Wrong Entry Data Type")
      return
    }
    
    XCTAssert(barcode == token)
  }
  
  func test_setToken_With_18DigitBarcode_Should_Create_EntryData() {
    let token = "486886987775100944a"
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = token
    
    guard let entryData = secureEntryView.entryData, case .qrCode(let barcode) = entryData else {
      XCTFail("Wrong Entry Data Type")
      return
    }
    
    XCTAssert(barcode == token)
  }
  
  func test_setToken_With_InvalidJson_Should_Create_Ivalid_EntryData() {
    let secureEntryView: SecureEntryView = SecureEntryView()
    secureEntryView.token = "81948194819481f="
    
    if let entryData = secureEntryView.entryData,
      case .invalid = entryData { }
    else { XCTFail("Wrong Entry Data") }
  }
  
  func test_decodedSecret_Should_Match_ExpectedValue() {
    
    let secret: String = "45b4673ce3dca0a50fbb29cea6ae3efcc1d28abc"
    let expected: [Int8] = [69, -76, 103, 60, -29, -36, -96, -91, 15, -69, 41, -50, -90, -82, 62, -4,
                            -63, -46, -118, -68]
    
    guard let bytes: Data = EntryData.encodeOTPSecretBytes(secret) else {
      XCTAssert(false, "Encoded bytes should NOT be nil")
      return
    }
    let actual: [Int8] = bytes.withUnsafeBytes {
      [Int8](UnsafeBufferPointer(start: $0, count: bytes.count))
    }
    
    XCTAssertEqual(expected, actual)
  }
}
