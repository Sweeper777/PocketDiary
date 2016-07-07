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
        
        }
        let staticText = app.collectionViews.staticTexts[num]
        staticText.tap()
        snapshot("2preview")
        app.buttons["Editor"].tap()
        snapshot("3editor")
        app.navigationBars["6/26/16"].buttons["Cancel"].tap()
        app.navigationBars["My Diaries"].buttons["search filled"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.textFields["Search"].tap()
        tablesQuery.textFields["Search"].typeText("beach")
        snapshot("4search")
        app.navigationBars["Search"].buttons["search colored"].tap()
        app.navigationBars["Results - 1 / 2"].buttons["right"].tap()
        
        snapshot("5result")
    }
    
}
