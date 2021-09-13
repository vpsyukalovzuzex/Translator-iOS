//
// WebTranslationViewController.swift
//

import UIKit
import WebKit

class WebTranslationViewController: UIViewController, UISearchBarDelegate, WKNavigationDelegate/*, LangSelectDelegate*/ {
    
    @IBOutlet private weak var closeButton:   UIButton!
    @IBOutlet private weak var refreshButton: UIButton!
    
    @IBOutlet private weak var searchBar: UISearchBar!
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var fromLanguageButton: UIButton!
    @IBOutlet weak var toLanguageButton:   UIButton!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private var shouldTranslate = true
    
    private var originalString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        searchBar.inputAccessoryView = UIToolbar.tranlation(
            target: self,
            cancel: #selector(cancelAction(_:)),
            translate: #selector(translateAction(_:))
        )
        updateLanguages()
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refreshButtonAction(_ sender: Any) {
        webView.reload()
    }
    
    @IBAction func fromLanguageButtonAction(_ sender: UIButton) {
        // TJLangSelectController.showLanguagesViewController(with: .from, for: self, delegate: self)
    }
    
    @IBAction func toLanguageButtonAction(_ sender: UIButton) {
        // TJLangSelectController.showLanguagesViewController(with: .to, for: self, delegate: self)
    }
    
    @objc private func cancelAction(_ sender: UIBarButtonItem) {
        shouldTranslate = false
        searchBar.resignFirstResponder()
    }
    
    @objc private func translateAction(_ sender: UIBarButtonItem) {
        shouldTranslate = true
        searchBar.resignFirstResponder()
    }
    
    private func translate() {
        if !shouldTranslate {
            shouldTranslate = true
            return
        }
        guard
            let string = searchBar.text,
            !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return
        }
        _translate(string)
    }
    
    private func _translate(_ string: String) {
        // originalString = string
        // let from = TJSettingsService.languageFrom()
        // let to = TJSettingsService.languageTo()
        // indicator.startAnimating()
        // TJRequestManager.instance()?.translateWebPage(
        //     withUrlString: string,
        //     languageFrom: from,
        //     languageTo: to,
        //     success: { [weak self] urlString in
        //         self?.indicator.stopAnimating()
        //         guard
        //             let urlString = urlString,
        //             let url = URL(string: urlString)
        //         else {
        //             return
        //         }
        //         self?.webView.load(URLRequest(url: url))
        //     }, failure: { [weak self] _ in
        //         self?.indicator.stopAnimating()
        //     })
    }
    
    private func updateLanguages() {
        // guard let settings = TJSettingsService.defaultSettings() else {
        //     return
        // }
        // let from = settings.languageFrom.languageString.uppercased()
        // let to = settings.languageTo.languageString.uppercased()
        // fromLanguageButton.setTitle(from, for: .normal)
        // toLanguageButton.setTitle(to, for: .normal)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        translate()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        shouldTranslate = true
        searchBar.resignFirstResponder()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            if let string = navigationAction.request.url?.absoluteString {
                _translate(string)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        indicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        indicator.stopAnimating()
    }
    
    // func itemSelected(_ item: TJLanguageRealm!, direction: LanguageDirection) {
    //     var isChanged = false
    //     if direction == .from {
    //         if TJSettingsService.defaultSettings()?.languageFrom != item {
    //             TJSettingsService.setLanguageFrom(item)
    //             isChanged = true
    //         }
    //     } else {
    //         if TJSettingsService.defaultSettings()?.languageTo != item {
    //             TJSettingsService.setLanguageTo(item)
    //             isChanged = true
    //         }
    //     }
    //     if isChanged {
    //         updateLanguages()
    //         if let string = originalString {
    //             _translate(string)
    //         }
    //     }
    // }
}
