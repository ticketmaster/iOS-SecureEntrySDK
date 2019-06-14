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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_init_withDefaultBrandingColor() {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		XCTAssertEqual(secureEntryView.brandingColor, nil)
    }
	
	func test_setBrandingColor_Should_Set_BrandingColor() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		secureEntryView.setBrandingColor(color: UIColor.purple);
		
		// then
		XCTAssertEqual(secureEntryView.brandingColor, UIColor.purple)
	}
    
    func test_setBarcodeSubtitle_Should_Set_BarcodeSubtitle() {
        let secureEntryView: SecureEntryView = SecureEntryView()
        
        // when
        secureEntryView.setPdf417Subtitle(subtitleText: "Screenshots are a no go!")
        secureEntryView.setQrCodeSubtitle(subtitleText: "Screenshots are a no go!")
        
        //then
        XCTAssertEqual(secureEntryView.pdf417BarcodeSubtitle, "Screenshots are a no go!")
        XCTAssertEqual(secureEntryView.qrBarcodeSubtitle, "Screenshots are a no go!")
    }
    
    func test_setBarcodeSubtitle_Blank_Should_Set_BarcodeSubtitleBlank() {
        let secureEntryView: SecureEntryView = SecureEntryView()
        
        //when
        secureEntryView.setPdf417Subtitle(subtitleText: "")
        secureEntryView.setQrCodeSubtitle(subtitleText: "")

        //then
        XCTAssertTrue(secureEntryView.pdf417BarcodeSubtitle.isEmpty)
        XCTAssertTrue(secureEntryView.pdf417BarcodeSubtitleBlank)
        XCTAssertTrue(secureEntryView.qrBarcodeSubtitle.isEmpty)
        XCTAssertTrue(secureEntryView.qrBarcodeSubtitleBlank)
        
    }
	
    func test_enableBrandingSubtitle_Should_Be_Colored() {
        let secureEntryView: SecureEntryView = SecureEntryView()
        
        //when
        secureEntryView.setBrandingColor(color: UIColor.purple)
        secureEntryView.enableBrandedSubtitle(enable: true)
        
        //then
        XCTAssertEqual(secureEntryView.qrSubtitleLabel?.textColor, UIColor.purple)
    }
    
    func test_enableBrandinSubtitle_False_Should_Be_Default_Color(){
        let secureEntryView: SecureEntryView = SecureEntryView()
        
        //when
        secureEntryView.setBrandingColor(color: UIColor.purple)
        
        //then
        XCTAssertEqual(secureEntryView.qrSubtitleLabel?.textColor, #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1))
    }
    
	func test_setErrorMessage_Should_Show_ErrorMessage() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		secureEntryView.showError(text: "Custom error text");
		
		// then
		let expectation = self.expectation(description: "syncTime")
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			XCTAssertEqual("Custom error text", secureEntryView.errorLabel?.text)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_V3RotatingData_Should_Create_EntryData() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: SecureEntryViewTests.V3_ROTATING_TOKEN);
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertEqual(entryData.getRenderType(), EntryData.RenderType.ROTATING);
				XCTAssertEqual(entryData.getBarcode(), "4868869877751009a");
				XCTAssertEqual(entryData.getToken(), "TM::03::7uxb9lagqczspsdbpdjh10n5acxsc2rbw6g0zq0kmum8dlcp6");
				XCTAssertEqual(entryData.getCustomerKey(), EntryData.encodeOTPSecretBytes("ee9f9fc004614219c69bc9f0630199dcb9b677bf"))
				XCTAssertNil(entryData.getEventKey())
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_V3QrData_Should_Create_EntryData() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: SecureEntryViewTests.V3_QR_CODE_TOKEN);
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertEqual(entryData.getRenderType(), EntryData.RenderType.STATIC_QR);
				XCTAssertEqual(entryData.getBarcode(), "4868869877751009a");
				XCTAssert(entryData.getToken().lengthOfBytes(using: String.Encoding.ascii) == 0)
				XCTAssertNil(entryData.getCustomerKey())
				XCTAssertNil(entryData.getEventKey())
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_V4StaticPdfData_Should_Create_EntryData() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: SecureEntryViewTests.V4_STATIC_PDF417_TOKEN);
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertEqual(entryData.getRenderType(), EntryData.RenderType.STATIC_PDF);
				XCTAssertEqual(entryData.getBarcode(), "830536665158k");
				XCTAssert(entryData.getToken().lengthOfBytes(using: String.Encoding.ascii) == 0)
				XCTAssertNil(entryData.getCustomerKey());
				XCTAssertNil(entryData.getEventKey())
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_Wit_V4RotatingData_Should_Create_EntryData() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: SecureEntryViewTests.V4_ROTATING_TOKEN);
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertEqual(entryData.getRenderType(), EntryData.RenderType.ROTATING);
				XCTAssertEqual(entryData.getBarcode(), "850061570257Q");
				XCTAssertEqual(entryData.getToken(), "BAIAWLFbizuOEQAAAAAAAAAAAACjuxwu9DezbxTPnKc8TaVLZlZOCzXaxxakJ1gV")
				XCTAssertEqual(entryData.getCustomerKey(), EntryData.encodeOTPSecretBytes("d7fa0a0e7872ac5d46628e2f9afd0111ec8e87bf"));
				XCTAssertEqual(entryData.getEventKey(), EntryData.encodeOTPSecretBytes("9a160509779e608adfee84bd27d0877a5cce9166"))
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_V4QrCodeData_Should_Create_EntryData() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: SecureEntryViewTests.V4_QR_CODE);
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertEqual(entryData.getRenderType(), EntryData.RenderType.STATIC_QR);
				XCTAssertEqual(entryData.getBarcode(), "0867346476041616a");
				XCTAssert(entryData.getToken().lengthOfBytes(using: String.Encoding.ascii) == 0)
				XCTAssertNil(entryData.getCustomerKey());
				XCTAssertNil(entryData.getEventKey())
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_generate_PdfBitmap_With_V3RotatingData_Should_Create_Pdf417Bitmap() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: SecureEntryViewTests.V3_ROTATING_TOKEN);
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let _: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertNotNil(secureEntryView.pdfImageView?.image)
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_generate_PdfBitmap_With_V4RotatingData_Should_Create_Pdf417Bitmap() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: SecureEntryViewTests.V4_ROTATING_TOKEN);
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let _: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertNotNil(secureEntryView.pdfImageView?.image)
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_generate_QrCodeBitmap_With_V3StaticData_Should_Create_QrCodeBitmap() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: SecureEntryViewTests.V4_ROTATING_TOKEN);
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let _: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertNotNil(secureEntryView.qrImageView?.image)
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_getNewOTP_With_V3RotatingData_Should_Create_Expected_MessageToEncode() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: SecureEntryViewTests.V3_ROTATING_TOKEN);
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				
				if TOTP.shared == nil {
					TOTP.update()
				}
				
				guard let totp = TOTP.shared else {
					XCTAssert(false, "TOTP should NOT be nil")
					expectation.fulfill()
					return
				}
				
				guard let customerNow = totp.generate(secret: entryData.getCustomerKey() ?? Data()) else {
					XCTAssert(false, "Customer OTP should NOT be nil")
					expectation.fulfill()
					return
				}
				
				XCTAssertNotNil(customerNow);
				XCTAssertNotNil(secureEntryView.pdfValue);
				XCTAssertEqual(secureEntryView.pdfValue!.components(separatedBy: "::").count, 4);
				XCTAssertEqual(secureEntryView.pdfValue!.components(separatedBy: "::")[3], customerNow);
				
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_getNewOTP_With_V4RotatingData_Should_Create_Expected_MessageToEncode() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: SecureEntryViewTests.V4_ROTATING_TOKEN);
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				
				if TOTP.shared == nil {
					TOTP.update()
				}
				
				guard let totp = TOTP.shared else {
					XCTAssert(false, "TOTP should NOT be nil")
					expectation.fulfill()
					return
				}
				
				guard let customerNow = totp.generate(secret: entryData.getCustomerKey() ?? Data()) else {
					XCTAssert(false, "Customer OTP should NOT be nil")
					expectation.fulfill()
					return
				}
				
				guard let eventNow = totp.generate(secret: entryData.getEventKey() ?? Data()) else {
					XCTAssert(false, "Customer OTP should NOT be nil")
					expectation.fulfill()
					return
				}
				
				XCTAssertNotNil(customerNow);
				XCTAssertNotNil(secureEntryView.pdfValue);
				XCTAssertEqual(secureEntryView.pdfValue!.components(separatedBy: "::").count, 3);
				XCTAssertEqual(secureEntryView.pdfValue!.components(separatedBy: "::")[1], eventNow);
				XCTAssertEqual(secureEntryView.pdfValue!.components(separatedBy: "::")[2], customerNow);
				
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_Null_Should_Have_DefaultErrorMessage() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: nil);
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				
				if let _: EntryData = secureEntryView.entryData {
					XCTAssert(false, "Entry data should be nil")
					expectation.fulfill()
					return
				}
				
				XCTAssertEqual(SecureEntryConstants.Strings.DefaultErrorText, secureEntryView.errorLabel?.text);
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_Null_Should_Have_CustomErrorMessage() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: nil, errorText: "Hello, World!");
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				
				if let _: EntryData = secureEntryView.entryData {
					XCTAssert(false, "Entry data should be nil")
					expectation.fulfill()
					return
				}
				
				XCTAssertEqual("Hello, World!", secureEntryView.errorLabel?.text);
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_InvalidJson_Should_Have_DefaultErrorMessage() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: "Invalid JSON payload");
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			
				if let _: EntryData = secureEntryView.entryData {
					XCTAssert(false, "Entry data should be nil")
					expectation.fulfill()
					return
				}
				
				XCTAssertEqual(SecureEntryConstants.Strings.DefaultErrorText, secureEntryView.errorLabel?.text);
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_12DigitBarcode_Should_Create_EntryData() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: "486886987775a");
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertEqual(entryData.getRenderType(), EntryData.RenderType.STATIC_QR);
				XCTAssertEqual(entryData.getBarcode(), "486886987775a");
				XCTAssert(entryData.getToken().lengthOfBytes(using: String.Encoding.ascii) == 0)
				XCTAssertNil(entryData.getCustomerKey());
				XCTAssertNil(entryData.getEventKey())
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_13DigitBarcode_Should_Create_EntryData() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: "4868869877751a");
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertEqual(entryData.getRenderType(), EntryData.RenderType.STATIC_QR);
				XCTAssertEqual(entryData.getBarcode(), "4868869877751a");
				XCTAssert(entryData.getToken().lengthOfBytes(using: String.Encoding.ascii) == 0)
				XCTAssertNil(entryData.getCustomerKey());
				XCTAssertNil(entryData.getEventKey())
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_14DigitBarcode_Should_Create_EntryData() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: "48688698777510a");
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertEqual(entryData.getRenderType(), EntryData.RenderType.STATIC_QR);
				XCTAssertEqual(entryData.getBarcode(), "48688698777510a");
				XCTAssert(entryData.getToken().lengthOfBytes(using: String.Encoding.ascii) == 0)
				XCTAssertNil(entryData.getCustomerKey());
				XCTAssertNil(entryData.getEventKey())
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_15DigitBarcode_Should_Create_EntryData() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: "486886987775100a");
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertEqual(entryData.getRenderType(), EntryData.RenderType.STATIC_QR);
				XCTAssertEqual(entryData.getBarcode(), "486886987775100a");
				XCTAssert(entryData.getToken().lengthOfBytes(using: String.Encoding.ascii) == 0)
				XCTAssertNil(entryData.getCustomerKey());
				XCTAssertNil(entryData.getEventKey())
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_16DigitBarcode_Should_Create_EntryData() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: "4868869877751009a");
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertEqual(entryData.getRenderType(), EntryData.RenderType.STATIC_QR);
				XCTAssertEqual(entryData.getBarcode(), "4868869877751009a");
				XCTAssert(entryData.getToken().lengthOfBytes(using: String.Encoding.ascii) == 0)
				XCTAssertNil(entryData.getCustomerKey());
				XCTAssertNil(entryData.getEventKey())
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_17DigitBarcode_Should_Create_EntryData() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: "48688698777510094a");
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertEqual(entryData.getRenderType(), EntryData.RenderType.STATIC_QR);
				XCTAssertEqual(entryData.getBarcode(), "48688698777510094a");
				XCTAssert(entryData.getToken().lengthOfBytes(using: String.Encoding.ascii) == 0)
				XCTAssertNil(entryData.getCustomerKey());
				XCTAssertNil(entryData.getEventKey())
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_18DigitBarcode_Should_Create_EntryData() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: "486886987775100944a");
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertEqual(entryData.getRenderType(), EntryData.RenderType.STATIC_QR);
				XCTAssertEqual(entryData.getBarcode(), "486886987775100944a");
				XCTAssert(entryData.getToken().lengthOfBytes(using: String.Encoding.ascii) == 0)
				XCTAssertNil(entryData.getCustomerKey());
				XCTAssertNil(entryData.getEventKey())
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_InvalidJson_Should_Not_Create_EntryData() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: "81948194819481f=");
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				if let _: EntryData = secureEntryView.entryData {
					XCTAssert(false, "Entry data should be nil")
					expectation.fulfill()
					return
				}
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
	}
	
	func test_setToken_With_ValidBase64TokenAndInvalidJson_Should_Create_EntryData() {
		let secureEntryView: SecureEntryView = SecureEntryView()
		
		// when
		let expectation = self.expectation(description: "syncTime")
		secureEntryView.syncTime(completed: { (completed) in
			
			secureEntryView.setToken(token: "81948194819481f");
			
			// then
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				guard let entryData: EntryData = secureEntryView.entryData else {
					XCTAssert(false, "Entry data should NOT be nil")
					expectation.fulfill()
					return
				}
				XCTAssertEqual(entryData.getRenderType(), EntryData.RenderType.STATIC_QR);
				XCTAssertEqual(entryData.getBarcode(), "81948194819481f");
				XCTAssert(entryData.getToken().lengthOfBytes(using: String.Encoding.ascii) == 0)
				XCTAssertNil(entryData.getCustomerKey());
				XCTAssertNil(entryData.getEventKey())
				expectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: 15, handler: nil)
		XCTAssertNotNil(secureEntryView)
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
