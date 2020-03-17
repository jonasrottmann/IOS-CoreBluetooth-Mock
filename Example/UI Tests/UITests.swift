/*
* Copyright (c) 2020, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import XCTest

class nRFBlinky_UITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testConnection() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["mocking-enabled"]
        app.launch()
        
        // Start scanning
        let scanner = app.tables["scanResults"]
        XCTAssert(scanner.cells["nRF Blinky"].waitForExistence(timeout: 0.5))
        
        // Wait for device to appear and tap it.
        XCTAssertEqual(scanner.cells.count, 1)
        scanner.cells["nRF Blinky"].tap()
        
        let control = app.tables["control"]
        let ledState = control.staticTexts["ledState"]
        let buttonState = control.staticTexts["buttonState"]
        let ledSwitch = control.switches["ledSwitch"]
        XCTAssertEqual(ledState.label, "UNKNOWN")
        XCTAssertEqual(buttonState.label, "UNKNOWN")
        
        // Wait for the device to connect.
        sleep(1)
        XCTAssertEqual(ledState.label, "OFF")
        XCTAssertEqual(buttonState.label, "RELEASED")
        XCTAssert(ledSwitch.isOn == false)
        
        // Tap LED switch to turn the LED on.
        ledSwitch.tap()
        XCTAssert(ledSwitch.isOn == true)
        XCTAssertEqual(ledState.label, "ON")
        
        // A button notification should also be received at this time.
        XCTAssertEqual(buttonState.label, "PRESSED")
        
        // Tap the LED switch again to disable it.
        ledSwitch.tap()
        XCTAssert(ledSwitch.isOn == false)
        XCTAssertEqual(ledState.label, "OFF")
        
        // Navigating back and disconnecting.
        app.buttons["Scanner"].tap()
        XCTAssertEqual(scanner.cells.count, 0)
        
        // nRF Blinky should start advertising quickly.
        XCTAssert(scanner.cells["nRF Blinky"].waitForExistence(timeout: 2.0))
        XCTAssertEqual(scanner.cells.count, 1)
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}

private extension XCUIElement {
    
    var isOn: Bool {
        if let value = value as? String {
            return value == "1"
        }
        return false
    }
    
}
