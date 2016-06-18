import UIKit

class SearchResultsController: UIViewController, UIWebViewDelegate {
    var entries: [Entry] = []
    var searchText: String!
    var nowDisplayingIndex = -1
    var highlighted = false
    
    @IBOutlet var resultView: UIWebView!
    
    @IBAction func next(sender: UIBarButtonItem) {
        loadNextResult()
    }
    
    @IBAction func previous(sender: UIBarButtonItem) {
        loadPreviousResult()
    }
    
    override func viewDidLoad() {
        automaticallyAdjustsScrollViewInsets = false
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
            
            resultView.loadHTMLString(entries[nowDisplayingIndex].htmlDescriptionForSearchMode(.TitleOnly), baseURL: nil)
            highlighted = false
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
            
            resultView.loadHTMLString(entries[nowDisplayingIndex].htmlDescriptionForSearchMode(.TitleOnly), baseURL: nil)
            highlighted = false
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if highlighted {
            return
        }
        
        webView.stringByEvaluatingJavaScriptFromString("highlightSearch(\"\(searchText)\")")
        
        highlighted = true
    }
}
