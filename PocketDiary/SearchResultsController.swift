import UIKit
import Emoji

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
