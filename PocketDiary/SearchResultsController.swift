import UIKit
import Emoji

class SearchResultsController: UIViewController, UIWebViewDelegate {
    var entries: [Entry] = []
    var searchText: String!
    var nowDisplayingIndex = -1
    var searchMode: SearchRange!
    var exactMatch: Bool!
    
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
        //resultView.initializeHighlighting()
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
            
            resultView.loadHTMLString(entries[nowDisplayingIndex].htmlDescriptionForSearchMode(searchMode), baseURL: nil)
            //resultView.initializeHighlighting()
            //resultView.highlightAllOccurencesOfString(searchText)
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
            
            resultView.loadHTMLString(entries[nowDisplayingIndex].htmlDescriptionForSearchMode(searchMode), baseURL: NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath))
            //resultView.initializeHighlighting()
            //resultView.highlightAllOccurencesOfString(searchText)
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.initializeHighlighting()
        
        if exactMatch == true {
            webView.stringByEvaluatingJavaScriptFromString("uiWebview_HighlightAllOccurencesOfString('\(searchText.emojiUnescapedString)')")
        } else {
            let keywords = searchText.componentsSeparatedByString(" ").filter { $0 != "" }
            for keyword in keywords {
                webView.stringByEvaluatingJavaScriptFromString("uiWebview_HighlightAllOccurencesOfString('\(keyword.emojiUnescapedString)')")
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
