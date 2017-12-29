//
//  NewsNetUITests.swift
//  NewsNetUITests
//
//  Created by Genaro Codina Reverter on 28/12/2017.
//  Copyright © 2017 Genaro Codina Reverter. All rights reserved.
//

import XCTest

class NewsNetUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    var currentLanguage: (langCode: String, localeCode: String)? {
        let currentLocale = Locale(identifier: Locale.preferredLanguages.first!)
        guard let langCode = currentLocale.languageCode else {
            return nil
        }
        var localeCode = langCode
        if let scriptCode = currentLocale.scriptCode {
            localeCode = "\(langCode)-\(scriptCode)"
        } else if let regionCode = currentLocale.regionCode {
            localeCode = "\(langCode)-\(regionCode)"
        }
        return (langCode, localeCode)
    }
        
    override func setUp() {
        
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()

    }
    
    override func tearDown() {
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNewspaperViewControllerTitle() {
        
        // We send a command line argument to our app,
        // to enable it to reset its state
        app.launchArguments.append("--uitesting")
        
        XCUIDevice.shared.orientation = .faceUp
        
        app.launch()
        
        //let titleStr = localizedString("newpapers")
        
        
        XCTAssert(app.navigationBars["Newspapers"].exists)
    }
    
    func localizedString(_ key: String) -> String {
        
        let testBundle = Bundle(for: NewsNetUITests.self)
        if let currentLanguage = currentLanguage,
            let testBundlePath = testBundle.path(forResource: currentLanguage.localeCode, ofType: "lproj") ??
                testBundle.path(forResource :
                currentLanguage.langCode, ofType: "lproj"),
            let localizedBundle = Bundle(path: testBundlePath)
        {
            return NSLocalizedString(key, bundle: localizedBundle, comment: "")
        }
        return "?"
    }
}
