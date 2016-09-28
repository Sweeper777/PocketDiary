import XCTest

class PocketDiaryUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        setupSnapshot(XCUIApplication())
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        let app = XCUIApplication()
        app.collectionViews.staticTexts["13"].swipeRight()
        snapshot("1calendar")
        
        var num = ""
        
        if deviceLanguage.hasPrefix("en") {
            num = "26"
        } else if deviceLanguage.hasSuffix("Hans") {
            num = "15"
        } else if deviceLanguage.hasSuffix("Hant") {
            num = "14"
        }
        
    
        app.collectionViews.staticTexts[num].tap()
        snapshot("2preview")
        app.buttons.element(boundBy: 5).tap()
        snapshot("3editor")
        if UIDevice.current.userInterfaceIdiom == .pad {
            app.navigationBars.element(boundBy: 0).buttons.element(boundBy: 1).tap()
            app.navigationBars.element(boundBy: 0).buttons.element(boundBy: 1).tap()
        } else {
            app.navigationBars.element(boundBy: 0).buttons.element(boundBy: 0).tap()
            app.navigationBars.element(boundBy: 0).buttons.element(boundBy: 1).tap()
        }
        
        let tablesQuery = app.tables
        tablesQuery.textFields.element(boundBy: 0).tap()
        
        var text = ""
        
        if deviceLanguage.hasPrefix("en") {
            text = "beach"
        } else {
            text = "我"
        }
        
        tablesQuery.textFields.element(boundBy: 0).typeText(text)
        snapshot("4search")
        if UIDevice.current.userInterfaceIdiom == .pad {
            app.navigationBars.element(boundBy: 1).buttons.element(boundBy: 2).tap()
        } else {
            app.navigationBars.element(boundBy: 0).buttons.element(boundBy: 2).tap()
        }
        if deviceLanguage.hasSuffix("Hans") {
            snapshot("5result")
        } else {
            if UIDevice.current.userInterfaceIdiom == .pad {
                app.navigationBars.element(boundBy: 1).buttons.element(boundBy: 2).tap()
            } else {
                app.navigationBars.element(boundBy: 0).buttons.element(boundBy: 2).tap()
            }
            
            snapshot("5result")
        }
    }
    
}
