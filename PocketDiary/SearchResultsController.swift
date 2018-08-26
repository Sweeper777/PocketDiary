import UIKit
import Emoji
import GoogleMobileAds

class SearchResultsController: UIViewController/*, UIWebViewDelegate*/ {
//    var entries: [Int] = []
//    var searchText: String!
//    var nowDisplayingIndex = -1
//    var searchMode: SearchRange!
//    var exactMatch: Bool!
//
//    lazy var htmls: [String] = {
//        return self.entries.map { $0.htmlDescriptionForSearchMode(self.searchMode) }
//    }()
//
//    @IBOutlet var resultView: UIWebView!
//    @IBOutlet var ad: GADBannerView!
//    @IBOutlet var noResultLabel: UILabel!
//
//    @IBAction func next(_ sender: UIBarButtonItem) {
//        loadNextResult()
//    }
//
//    @IBAction func previous(_ sender: UIBarButtonItem) {
//        loadPreviousResult()
//    }
//
//    override func viewDidLoad() {
//        automaticallyAdjustsScrollViewInsets = false
//
//        UINavigationBar.appearance().barStyle = .black
//        self.navigationController?.navigationBar.tintColor = UIColor.white
//
//        resultView.delegate = self
//        loadNextResult()
//
//        resultView.scrollView.showsVerticalScrollIndicator = false
//        resultView.scrollView.showsHorizontalScrollIndicator = false
//        resultView.scrollView.bounces = true
//
//        ad.adUnitID = AdUtility.ad3ID
//        ad.rootViewController = self
//        ad.load(AdUtility.getRequest())
//    }
//
//    fileprivate func loadNextResult() {
//        if entries.count > 0 {
//            if nowDisplayingIndex == entries.count - 1 {
//                nowDisplayingIndex = 0
//            } else {
//                nowDisplayingIndex += 1
//            }
//
//            title = NSLocalizedString("Results - ", comment: "") + "\(nowDisplayingIndex + 1) / \(entries.count)"
//
//            resultView.loadHTMLString(htmls[nowDisplayingIndex], baseURL: nil)
//            view.backgroundColor = entries[nowDisplayingIndex].bgColor?.toColor() ?? UIColor.white
//            resultView.backgroundColor = entries[nowDisplayingIndex].bgColor?.toColor() ?? UIColor.white
//        } else  {
//            navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
//            resultView.isHidden = true
//            if exactMatch! {
//                noResultLabel.text = String(format: NSLocalizedString("Oops! There are no entries that exactly matches \"%@\"!", comment: ""), searchText)
//            } else {
//                noResultLabel.text = String(format: NSLocalizedString("Oops! There are no entries that matches \"%@\"!", comment: ""), searchText)
//            }
//            noResultLabel.isHidden = false
//        }
//    }
//
//    fileprivate func loadPreviousResult() {
//        if entries.count > 0 {
//
//            if nowDisplayingIndex == 0 {
//                nowDisplayingIndex = entries.count - 1
//            } else {
//                nowDisplayingIndex -= 1
//            }
//
//            title = NSLocalizedString("Results - ", comment: "") + "\(nowDisplayingIndex + 1) / \(entries.count)"
//
//            resultView.loadHTMLString(htmls[nowDisplayingIndex], baseURL: nil)
//            view.backgroundColor = entries[nowDisplayingIndex].bgColor?.toColor() ?? UIColor.white
//            resultView.backgroundColor = entries[nowDisplayingIndex].bgColor?.toColor() ?? UIColor.white
//        }
//    }
//
//    func webViewDidFinishLoad(_ webView: UIWebView) {
//        webView.initializeHighlighting()
//
//        if exactMatch == true {
//            webView.stringByEvaluatingJavaScript(from: "uiWebview_HighlightAllOccurencesOfString(\"\(searchText.emojiUnescapedString)\", \(exactMatch!))")
//        } else {
//            let keywords = searchText.components(separatedBy: " ").filter { $0 != "" }
//            for keyword in keywords {
//                webView.stringByEvaluatingJavaScript(from: "uiWebview_HighlightAllOccurencesOfString(\"\(keyword.emojiUnescapedString)\", \(exactMatch!))")
//            }
//        }
//    }
}

extension UIWebView {
    func initializeHighlighting() {
        let path = Bundle.main.path(forResource: "highlight", ofType: "js")
        let jsCode = try! String(contentsOfFile: path!)
        _ = self.stringByEvaluatingJavaScript(from: jsCode)!
    }
}
