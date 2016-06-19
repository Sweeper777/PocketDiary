import UIKit

class SearchResultsController: UIViewController, UIWebViewDelegate {
    var entries: [Entry] = []
    var searchText: String!
    var nowDisplayingIndex = -1
    
    @IBOutlet var resultView: UIWebView!
    
    @IBAction func next(sender: UIBarButtonItem) {
        loadNextResult()
    }
    
    @IBAction func previous(sender: UIBarButtonItem) {
        loadPreviousResult()
    }
    
    @IBAction func highlight(sender: UIBarButtonItem) {
        resultView.stringByEvaluatingJavaScriptFromString("uiWebview_HighlightAllOccurencesOfString('\(searchText)')")
    }
    
    override func viewDidLoad() {
        automaticallyAdjustsScrollViewInsets = false
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
            
            resultView.loadHTMLString(entries[nowDisplayingIndex].htmlDescriptionForSearchMode(.TitleOnly), baseURL: nil)
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
            
            resultView.loadHTMLString(entries[nowDisplayingIndex].htmlDescriptionForSearchMode(.TitleOnly), baseURL: NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath))
            //resultView.initializeHighlighting()
            //resultView.highlightAllOccurencesOfString(searchText)
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.initializeHighlighting()
        
        webView.stringByEvaluatingJavaScriptFromString("uiWebview_HighlightAllOccurencesOfString('\(searchText)')")
    }
}

extension UIWebView {
    func initializeHighlighting() {
        let path = NSBundle.mainBundle().pathForResource("highlight", ofType: "js")
        let jsCode = try! String(contentsOfFile: path!)
        self.stringByEvaluatingJavaScriptFromString(jsCode)!
    }
}
