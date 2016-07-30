import UIKit
import Emoji
import GoogleMobileAds
import EZSwiftExtensions

class SearchResultsController: UIViewController, UIWebViewDelegate {
    var entries: [Entry] = []
    var searchText: String!
    var nowDisplayingIndex = -1
    var searchMode: SearchRange!
    var exactMatch: Bool!
    
    lazy var htmls: [String] = {
        return self.entries.map { $0.htmlDescriptionForSearchMode(self.searchMode) }
    }()
    
    @IBOutlet var resultView: UIWebView!
    @IBOutlet var ad: GADBannerView!
    @IBOutlet var noResultLabel: UILabel!
    
    @IBAction func next(sender: UIBarButtonItem) {
        loadNextResult()
    }
    
    @IBAction func previous(sender: UIBarButtonItem) {
        loadPreviousResult()
    }
    
    override func viewDidLoad() {
        automaticallyAdjustsScrollViewInsets = false
        
        UINavigationBar.appearance().barStyle = .Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        resultView.delegate = self
        loadNextResult()
        
        resultView.scrollView.showsVerticalScrollIndicator = false
        resultView.scrollView.showsHorizontalScrollIndicator = false
        resultView.scrollView.bounces = true
        
        ad.adUnitID = AdUtility.ad3ID
        ad.rootViewController = self
        ad.loadRequest(AdUtility.getRequest())
    }
    
    private func loadNextResult() {
        if entries.count > 0 {
            if nowDisplayingIndex == entries.count - 1 {
                nowDisplayingIndex = 0
            } else {
                nowDisplayingIndex += 1
            }
            
            title = NSLocalizedString("Results - ", comment: "") + "\(nowDisplayingIndex + 1) / \(entries.count)"
            
            resultView.loadHTMLString(htmls[nowDisplayingIndex], baseURL: nil)
            view.backgroundColor = entries[nowDisplayingIndex].bgColor?.toColor() ?? UIColor.whiteColor()
            resultView.backgroundColor = entries[nowDisplayingIndex].bgColor?.toColor() ?? UIColor.whiteColor()
        } else  {
            navigationItem.rightBarButtonItems?.forEach { $0.enabled = false }
            resultView.hidden = true
            if exactMatch! {
                noResultLabel.text = String(format: NSLocalizedString("Oops! There are no entries that exactly matches \"%@\"!", comment: ""), searchText)
            } else {
                noResultLabel.text = String(format: NSLocalizedString("Oops! There are no entries that matches \"%@\"!", comment: ""), searchText)
            }
            noResultLabel.hidden = false
        }
    }
    
    private func loadPreviousResult() {
        if entries.count > 0 {
            
            if nowDisplayingIndex == 0 {
                nowDisplayingIndex = entries.count - 1
            } else {
                nowDisplayingIndex -= 1
            }
            
            title = NSLocalizedString("Results - ", comment: "") + "\(nowDisplayingIndex + 1) / \(entries.count)"
            
            resultView.loadHTMLString(htmls[nowDisplayingIndex], baseURL: nil)
            view.backgroundColor = entries[nowDisplayingIndex].bgColor?.toColor() ?? UIColor.whiteColor()
            resultView.backgroundColor = entries[nowDisplayingIndex].bgColor?.toColor() ?? UIColor.whiteColor()
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.initializeHighlighting()
        
        if exactMatch == true {
            webView.stringByEvaluatingJavaScriptFromString("uiWebview_HighlightAllOccurencesOfString('\(searchText.emojiUnescapedString)', \(exactMatch))")
        } else {
            let keywords = searchText.componentsSeparatedByString(" ").filter { $0 != "" }
            for keyword in keywords {
                webView.stringByEvaluatingJavaScriptFromString("uiWebview_HighlightAllOccurencesOfString('\(keyword.emojiUnescapedString)', \(exactMatch))")
            }
        }
    }
}

extension UIWebView {
    func initializeHighlighting() {
        let path = NSBundle.mainBundle().pathForResource("highlight", ofType: "js")
        let jsCode = try! String(contentsOfFile: path!)
        self.stringByEvaluatingJavaScriptFromString(jsCode)!
    }
}
