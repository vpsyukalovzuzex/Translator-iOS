//
//  TranslationViewController.swift
//

/*
 
 A - is original things.
 B - is translated thigs.
 
 */

import UIKit
import Common
// import AppTrackingTransparency
import NVActivityIndicatorView

private typealias Tuple = (isHidden: Bool, views: [UIView])

class TranslationViewController: UIViewController {
    
    struct Mode: OptionSet {
        
        static let translation = Mode(rawValue: 1 << 0)
        static let banner = Mode(rawValue: 1 << 1)
        static let dictionary = Mode(rawValue: 1 << 2)
        static let logo = Mode(rawValue: 1 << 3)
        
        static let all: Mode = [
            .translation,
            .banner,
            .dictionary,
            .logo
        ]
        
        static let standart: Mode = [
            .translation,
            .logo
        ]
        
        var rawValue: Int
        
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    // MARK: - Constant
    
    private let top: CGFloat = 16.0
    private let left: CGFloat = 0.0
    private let bottom: CGFloat = 64.0
    private let right: CGFloat = 0.0
    
    // MARK: - @IBOutlet
    
    @IBOutlet private weak var mainStackView: UIStackView!
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var stackViewA: UIStackView!
    
    @IBOutlet private weak var translationView: UIView!
    @IBOutlet private weak var bannerView: UIView!
    @IBOutlet private weak var dictionaryView: UIView!
    
    @IBOutlet private weak var logoImageView: UIImageView!
    
    @IBOutlet private weak var spacingViewA: UIView!
    @IBOutlet private weak var spacingViewB: UIView!
    @IBOutlet private weak var spacingViewC: UIView!
    
    @IBOutlet private weak var voiceButton: UIButton!
    @IBOutlet private weak var photoButton: UIButton!
    @IBOutlet private weak var websiteButton: UIButton!
    @IBOutlet private weak var documentButton: UIButton!
    @IBOutlet private weak var playButtonA: UIButton!
    
    @IBOutlet private weak var pasteButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var expandButton: UIButton!
    
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var copyButton: UIButton!
    @IBOutlet private weak var fullScreenButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var playButtonB: UIButton!
    
    @IBOutlet private weak var textViewA: UITextView!
    @IBOutlet private weak var textViewB: UITextView!
    
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet private weak var subBannerView: BannerView!
    
    @IBOutlet private weak var textViewLayoutConstraintA: NSLayoutConstraint!
    @IBOutlet private weak var textViewLayoutConstraintB: NSLayoutConstraint!
    
    @IBOutlet weak var languageButtonA: LanguageButton!
    @IBOutlet weak var languageButtonB: LanguageButton!
    
    @IBOutlet private weak var topLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var heightLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loaderLayoutConstraintA: NSLayoutConstraint!
    @IBOutlet weak var loaderLayoutConstraintB: NSLayoutConstraint!
    
    @IBOutlet private weak var autocompleteTableView: UITableView!
    @IBOutlet private weak var lexicalMeaningTableView: UITableView!
    
    @IBOutlet private weak var wordLabel: UILabel!
    @IBOutlet private weak var transcriptionLabel: UILabel!
    
    @IBOutlet private weak var logoSpacingLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var customActivityIndicator: NVActivityIndicatorView!
    
    // MARK: - Public
    
    public var translationModel: TranslationModel!
    
    public var mode: Mode {
        get { getMode() }
        set { setMode(newValue) }
    }
    
    public var textA: String? {
        get { textViewA.text }
        set { textViewA.text = newValue }
    }
    
    public var textB: String? {
        get { textViewB.text }
        set { textViewB.text = newValue }
    }
    
    public var isEmptyTextA: Bool { textA?.isEmpty ?? true }
    
    public var isEmptyTextB: Bool { textB?.isEmpty ?? true }
    
    public var isEmptyTexts: Bool { isEmptyTextA && isEmptyTextB }
    
    public var attributedTextA: NSAttributedString? {
        get { textViewA.attributedText }
        set { textViewA.attributedText = newValue }
    }
    
    public var attributedTextB: NSAttributedString? {
        get { textViewB.attributedText }
        set { textViewB.attributedText = newValue }
    }
    
    public var titleLanguageA: String? {
        get { languageButtonA.title }
        set { languageButtonA.title = newValue }
    }
    
    public var titleLanguageB: String? {
        get { languageButtonB.title }
        set { languageButtonB.title = newValue }
    }
    
    public var imageLanguageA: UIImage? {
        get { languageButtonA.image }
        set { languageButtonA.image = newValue }
    }
    
    public var imageLanguageB: UIImage? {
        get { languageButtonB.image }
        set { languageButtonB.image = newValue }
    }
    
    public var isSelectedPlayButtonA: Bool {
        get { playButtonA.isSelected }
        set { playButtonA.isSelected = newValue }
    }
    
    public var isSelectedPlayButtonB: Bool {
        get { playButtonB.isSelected }
        set { playButtonB.isSelected = newValue }
    }
    
    public var isSelectedFavoriteButton: Bool {
        get { favoriteButton.isSelected }
        set { favoriteButton.isSelected = newValue }
    }
    
    public var word: String? {
        get { wordLabel.text }
        set { wordLabel.text = newValue }
    }
    
    public var transcription: String? {
        get { transcriptionLabel.text }
        set { setTranscription(newValue) }
    }
    
    public var isVoiceEnabled: Bool {
        get { voiceButton.isEnabled }
        set { voiceButton.isEnabled = newValue }
    }
    
    public var isPhotoEnabled: Bool {
        get { photoButton.isEnabled }
        set { photoButton.isEnabled = newValue }
    }
    
    public var isRtlA: Bool {
        get { textViewA.textAlignment == .right }
        set { textViewA.textAlignment = newValue ? .right : .left }
    }
    
    public var isRtlB: Bool {
        get { textViewB.textAlignment == .right }
        set {
            textViewB.textAlignment = newValue ? .right : .left
            loaderLayoutConstraintA?.isActive = !newValue
            loaderLayoutConstraintB?.isActive =  newValue
        }
    }
    
    public var shareButtonRect: CGRect { getShareButtonRect() }
    
    public var autocompletes = [String]() { didSet { updateAutocompleteTableView() } }
    
    public var parts = [Any]() { didSet { lexicalMeaningTableView.reloadData() } }
    
    public var isCanPlayA = false { didSet { updatePlayButtons() } }
    public var isCanPlayB = false { didSet { updatePlayButtons() } }
    
    // MARK: - Private
    
    private var height: CGFloat { UIScreen.main.bounds.height }
    
    private var isSmall: Bool { height <= 667.0 }
    
    private var minHeightA: CGFloat { isSmall ? 94.0 : 138.0 }
    private var minHeightB: CGFloat { isSmall ? 94.0 : 138.0 }
    
    private var logoSpacing: CGFloat { isSmall ? 16.0 : 64.0 }
    
    private var isExpandedA: Bool {
        get { textViewLayoutConstraintA.constant > minHeightA }
        set { setIsExpandedA(newValue) }
    }
    
    private var isExpandedB: Bool {
        get { textViewLayoutConstraintB.constant > minHeightB }
        set { setIsExpandedB(newValue) }
    }
    
    private var isCanExpandA: Bool { minHeightA < heightA && !isKeyboardShow }
    
    private var isCanExpandB: Bool { minHeightB < heightB }
    
    private var heightA: CGFloat { textViewA.contentSize.height }
    
    private var heightB: CGFloat { textViewB.contentSize.height }
    
    private var typingHeight: CGFloat { getTypingHeight() }
    
    private var viewHeight: CGFloat { view.safeAreaLayoutGuide.layoutFrame.height }
    
    private var topInset: CGFloat { view.safeAreaInsets.top }
    
    private var bottomInset: CGFloat { tabBarController?.tabBar.frame.height ?? 0.0 }
    
    private var keyboardHeight: CGFloat = 0.0 { didSet { updateContentInset() } }
    
    private var isAnimating = false
    
    // MARK: - Keyboardable
    
    var isKeyboardShow = false
    var isNeededTranslate = true
    
    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        textViewA.removeObserver(self, forKeyPath: "text")
        textViewB.removeObserver(self, forKeyPath: "text")
        textViewA.removeObserver(self, forKeyPath: "attributedText")
        textViewB.removeObserver(self, forKeyPath: "attributedText")
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupUi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Analytics.track(.translation)
        if #available(iOS 14.0, *) {
            // if (TJSettingsService.defaultSettings()?.remoteSettings.showAdTrackerRequest.boolValue ?? false) {
            // ATTrackingManager.requestTrackingAuthorization { status in
                // Analytics.track(.translation, .requestTrackingAuthorization, status.parameters)
            // }
            // }
        }
        // translationModel.shouldShow()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "text" || keyPath == "attributedText" {
            guard let textView = object as? UITextView else {
                return
            }
            let string = change?[.newKey] as? String
            let attributedString = change?[.newKey] as? NSAttributedString
            let result = string ?? attributedString?.string
            if textView == textViewA {
                didCnahgeTextA(result)
            }
            if textView == textViewB {
                didCnahgeTextB(result)
            }
        }
    }
    
    // MARK: - Public
    
    public func focusOnTextViewA() {
        textViewA.becomeFirstResponder()
    }
    
    // MARK: - Private
    
    private func setup() {
        addObservers()
        addDelegates()
        setMode(.standart, animated: false)
        updateContentInset()
        translationModel = TranslationModel(viewController: self)
        translationModel.enter(nil)
    }
    
    private func setupUi() {
        textViewLayoutConstraintA.constant = minHeightA
        textViewLayoutConstraintB.constant = minHeightB
        logoSpacingLayoutConstraint.constant = logoSpacing
        textViewA.inputAccessoryView = UIToolbar.tranlation(
            target: self,
            cancel: #selector(cancelBarButtonItemAction(_:)),
            translate: #selector(translateBarButtonItemAction(_:))
        )
        autocompleteTableView.tableFooterView = UIView()
        updatePasteButton()
        customActivityIndicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    }
    
    private func addObservers() {
        let center = NotificationCenter.default
        addKeyboardObserver()
        addRotateObserver()
        textViewA.addObserver(self, forKeyPath: "text", options: [.new], context: nil)
        textViewB.addObserver(self, forKeyPath: "text", options: [.new], context: nil)
        textViewA.addObserver(self, forKeyPath: "attributedText", options: [.new], context: nil)
        textViewB.addObserver(self, forKeyPath: "attributedText", options: [.new], context: nil)
        center.addObserver(
            self,
            selector: #selector(pasteboardChanged(_:)),
            name: UIPasteboard.changedNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    private func addDelegates() {
        subBannerView.delegate = self
        view.addInteraction(UIDropInteraction(delegate: self))
    }
    
    private func tuples(for mode: Mode) -> [Tuple] {
        return [
            (isHidden: !mode.contains(.translation), views: [
                translationView
            ]),
            (isHidden: !mode.contains(.banner), views: [
                spacingViewA,
                bannerView
            ]),
            (isHidden: !mode.contains(.dictionary), views: [
                spacingViewB,
                dictionaryView
            ]),
            (isHidden: !mode.contains(.logo), views: [
                spacingViewC,
                logoImageView
            ]),
        ]
    }
    
    private func recursion(with tuples: [Tuple], _ block: @escaping () -> Void) {
        guard let item = tuples.first else {
            block()
            return
        }
        let isHidden = item.isHidden
        UIView.animate(withDuration: 0.2) {
            for view in item.views {
                if isHidden {
                    view.alpha = isHidden.alpha
                } else {
                    view.isHidden = isHidden
                }
            }
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                for view in item.views {
                    if isHidden {
                        view.isHidden = isHidden
                    } else {
                        view.alpha = isHidden.alpha
                    }
                }
            } completion: { _ in
                var copy = tuples
                copy.removeFirst()
                self.recursion(with: copy, block)
            }
        }
    }
    
    private func dismissInputTextViewA() {
        textViewA.resignFirstResponder()
    }
    
    private func autocomplete(by indexPath: IndexPath?) -> String? {
        guard let indexPath = indexPath else {
            return nil
        }
        let row = indexPath.row
        if row < autocompletes.count {
            return autocompletes[row]
        }
        return nil
    }
    
    private func part(by indexPath: IndexPath?) -> Any? {
        guard let indexPath = indexPath else {
            return nil
        }
        let row = indexPath.row
        if row < parts.count {
            return parts[row]
        }
        return nil
    }
    
    private func didCnahgeTextA(_ text: String?) {
        updateDeleteButton()
        updatePasteButton()
        updateExpandButton()
        updatePlaceholderLabel()
        updatePlayButtons()
    }
    
    private func didCnahgeTextB(_ text: String?) {
        updateDeleteButton()
        updatePasteButton()
        isExpandedB = isCanExpandB
        let isEnabled = !isEmptyTextB
        favoriteButton.isEnabled = isEnabled
        copyButton.isEnabled = isEnabled
        fullScreenButton.isEnabled = isEnabled
        shareButton.isEnabled = isEnabled
        updatePlayButtons()
    }
    
    private func updatePlayButtons() {
        playButtonA.isEnabled = !isEmptyTextA && isCanPlayA
        playButtonB.isEnabled = !isEmptyTextB && isCanPlayB
    }
    
    private func updateDeleteButton() {
        deleteButton.isHidden = isEmptyTexts
    }
    
    private func updatePasteButton() {
        pasteButton.isHidden = isEmptyTexts ? !UIPasteboard.general.hasStrings : true
    }
    
    private func updateExpandButton() {
        expandButton.isHidden = !isCanExpandA
    }
    
    private func updatePlaceholderLabel() {
        placeholderLabel.isHidden = !(textA?.isEmpty ?? true)
    }
    
    private func updateAutocompleteTableView() {
        autocompleteTableView.reloadData()
        autocompleteTableView.isHidden = autocompletes.isEmpty
    }
    
    // MARK: - get
    
    private func getMode() -> Mode {
        var result = Mode()
        if !translationView.isHidden {
            result.insert(.dictionary)
        }
        if !bannerView.isHidden {
            result.insert(.banner)
        }
        if !dictionaryView.isHidden {
            result.insert(.dictionary)
        }
        if !logoImageView.isHidden {
            result.insert(.logo)
        }
        return result
    }
    
    private func getTypingHeight() -> CGFloat {
        var result = viewHeight
        result -= top
        result -= topLayoutConstraint.constant
        result -= keyboardHeight
        result -= stackViewA.spacing
        result -= heightLayoutConstraint.constant
        return result
    }
    
    private  func getShareButtonRect() -> CGRect {
        let size: CGFloat = 32.0
        let bounds = shareButton.bounds
        let center = CGPoint(
            x: 0.5 * bounds.width,
            y: 0.5 * bounds.height
        )
        let rect = CGRect(
            x: center.x - 0.5 * size,
            y: center.y - 0.5 * size,
            width: size,
            height: size
        )
        return shareButton.convert(rect, to: view)
    }
    
    // MARK: - set
    
    public func setMode(_ mode: Mode, animated: Bool = true) {
        if self.mode == mode {
            return
        }
        let items = tuples(for: mode)
        if /* animated */ false {
            if isAnimating {
                return
            }
            isAnimating = true
            recursion(with: items) {
                self.isAnimating = false
            }
        } else {
            for item in items {
                let isHidden = item.isHidden
                for view in item.views {
                    view.layer.removeAllAnimations()
                    view.isHidden = isHidden
                    view.alpha = isHidden.alpha
                }
            }
            isAnimating = false
        }
    }
    
    private func setIsExpandedA(_ isExpanded: Bool, animated: Bool = true) {
        let height = isKeyboardShow ? typingHeight : heightA
        let constant = isExpanded ? height : minHeightA
        if constant == textViewLayoutConstraintA.constant {
            return
        }
        let angle: CGFloat = isExpanded ? .pi : 0.0
        let transform = CGAffineTransform(rotationAngle: angle)
        if animated {
            UIView.animate(withDuration: 0.4) {
                self.textViewLayoutConstraintA.constant = constant
                self.view.layoutIfNeeded()
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.expandButton.transform = transform
                }
            }
        } else {
            expandButton.transform = transform
            textViewLayoutConstraintA.constant = constant
        }
    }
    
    private func setIsExpandedB(_ isExpanded: Bool, animated: Bool = true) {
        let constant = isExpanded ? heightB : minHeightB
        if constant == textViewLayoutConstraintB.constant {
            return
        }
        if animated {
            UIView.animate(withDuration: 0.4) {
                self.textViewLayoutConstraintB.constant = constant
                self.view.layoutIfNeeded()
            }
        } else {
            textViewLayoutConstraintB.constant = constant
        }
    }
    
    private func setTranscription(_ transcription: String?) {
        let isNil = transcription == nil
        transcriptionLabel.text = isNil ? nil : "/\(transcription!)/"
        transcriptionLabel.isHidden = isNil
    }
    
    private func highlight(_ highlight: Bool, textView: UITextView) {
        let text = textView.attributedText ?? NSAttributedString(string: textView.text)
        let attributedText = NSMutableAttributedString(attributedString: text)
        let attributes: [NSAttributedString.Key : Any] = [
            .backgroundColor : highlight ? UIColor(named: "r_text_view_copy")! : UIColor.clear
        ]
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttributes(attributes, range: range)
        textView.attributedText = attributedText
    }
    
    // MARK: - didSet
    
    private func updateContentInset() {
        scrollView.contentInset = UIEdgeInsets(
            top: top,
            left: left,
            bottom: bottom + keyboardHeight,
            right: right
        )
    }
    
    // MARK: - @objc
    
    @objc private func pasteboardChanged(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.updatePasteButton()
        }
    }
    
    @objc private func applicationWillEnterForeground(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.updatePasteButton()
        }
    }
    
    @objc private func cancelBarButtonItemAction(_ sender: UIBarButtonItem) {
        // Analytics.track(.translation, .clickCancel, translationModel.standart)
        isNeededTranslate = false
        dismissInputTextViewA()
    }
    
    @objc private func translateBarButtonItemAction(_ sender: UIBarButtonItem) {
        // Analytics.track(.translation, .clickTranslate, translationModel.standart)
        dismissInputTextViewA()
    }
    
    // MARK: - @IBAction
    
    @IBAction private func voiceButtonTouchUpInsideAction(_ sender: UIButton) {
        translationModel.showVoiceViewController()
    }
    
    @IBAction private func photoButtonTouchUpInsideAction(_ sender: UIButton) {
        translationModel.showPhotoViewController()
    }
    
    @IBAction private func websiteButtonTouchUpInsideAction(_ sender: UIButton) {
        translationModel.showWebViewController()
    }
    
    @IBAction private func documentButtonTouchUpInsideAction(_ sender: UIButton) {
        translationModel.showDocumentViewController()
    }
    
    @IBAction private func playButtonATouchUpInsideAction(_ sender: UIButton) {
        translationModel.playTextA()
    }
    
    @IBAction private func pasteButtonTouchUpInside(_ sender: UIButton) {
        // Analytics.track(.translation, .clickPasteFromClipboard, translationModel.standart)
        textA = UIPasteboard.general.string
        translationModel.translate()
    }
    
    @IBAction private func deleteButtonTouchUpInsideAction(_ sender: UIButton) {
        // Analytics.track(.translation, .clickClear, translationModel.standart)
        translationModel.enter(nil)
        if !isKeyboardShow {
            isExpandedA = false
        }
        translationModel.translation = nil
    }
    
    @IBAction private func expandButtonTouchUpInsideAction(_ sender: UIButton) {
        isExpandedA = !isExpandedA
    }
    
    @IBAction private func favoriteButtonTouchUpInsideAction(_ sender: UIButton) {
        isSelectedFavoriteButton = !isSelectedFavoriteButton
        translationModel.switchFavorite()
    }
    
    @IBAction private func copyButtonTouchUpInsideAction(_ sender: UIButton) {
        // Analytics.track(.translation, .clickCopyToClipboard, translationModel.standart)
        UIPasteboard.general.string = textB
        highlight(true, textView: textViewB)
        textViewB.transform = CGAffineTransform(translationX: 0.0, y: 2.0)
        UIView.animate(
            withDuration: 0.4,
            delay: 0.0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 8.0,
            options: .curveEaseInOut,
            animations: {
                self.textViewB.transform = .identity
            },
            completion: { _ in
                self.highlight(false, textView: self.textViewB)
            }
        )
    }
    
    @IBAction private func fullScreenButtonTouchUpInsideAction(_ sender: UIButton) {
        translationModel.showFullScreenViewController()
    }
    
    @IBAction private func shareButtonTouchUpInsideAction(_ sender: UIButton) {
        translationModel.showShareViewController()
    }
    
    @IBAction private func playButtonBTouchUpInsideAction(_ sender: UIButton) {
        translationModel.playTextB()
    }
    
    @IBAction private func languageButtonATouchUpInsideAction(_ sender: LanguageButton) {
        translationModel.showLanguagesViewControllerForA()
    }
    
    @IBAction private func languageButtonBTouchUpInsideAction(_ sender: LanguageButton) {
        translationModel.showLanguagesViewControllerForB()
    }
    
    @IBAction private func switchButtonTouchUpInsideAction(_ sender: UIButton) {
        if let textB = textB {
            textA = textB
            self.textB = nil
        }
        translationModel.switchLanguages()
    }
}

extension TranslationViewController: Keyboardable {
    
    func keyboardWillShow(_ isShow: Bool, beginFrame: CGRect, endFrame: CGRect, duration: CGFloat) {
        guard textViewA.isFirstResponder else {
            return
        }
        scrollUp(animated: false)
        scrollView.isScrollEnabled = !isShow
        keyboardHeight = isShow ? endFrame.height - bottomInset : 0.0
        isExpandedA = isShow
        updateExpandButton()
        asyncAfter(0.2) { [weak self] in
            guard let self = self else {
                return
            }
            self.translationModel.enter(nil)
        }
    }
    
    func keyboardDidShow(_ isShow: Bool, beginFrame: CGRect, endFrame: CGRect, duration: CGFloat) {
        if !isNeededTranslate || isShow {
            isNeededTranslate = true
            return
        }
        translationModel.translate()
    }
}

extension TranslationViewController: Rotatable {
    
    func deviceOrientationDidChange(_ orientation: UIDeviceOrientation) {
        let orientations: [UIDeviceOrientation] = [.landscapeLeft, .landscapeRight, .portrait]
        guard orientations.contains(orientation) else {
            return
        }
        asyncAfter(1.0) { [weak self] in
            guard let self = self else {
                return
            }
            self.setIsExpandedA(self.isExpandedA)
            self.setIsExpandedB(self.isExpandedB)
        }
    }
}

extension TranslationViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text
        if textView == textViewA {
            didCnahgeTextA(text)
            translationModel.enter(text?.onlyOneWord)
        }
        if textView == textViewB {
            didCnahgeTextB(text)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let condition = translationModel.shouldUseReturnKey && text == "\n"
        if condition {
            isNeededTranslate = true
            dismissInputTextViewA()
        }
        return !condition
    }
}

extension TranslationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == autocompleteTableView {
            return 1
        }
        if tableView == lexicalMeaningTableView {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == autocompleteTableView {
            return autocompletes.count
        }
        if tableView == lexicalMeaningTableView {
            return parts.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == autocompleteTableView {
            if let autocomplete = autocomplete(by: indexPath) {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AutocompleteTableViewCell.self), for: indexPath)
                if let cell = cell as? AutocompleteTableViewCell {
                    cell.title = autocomplete
                }
                return cell
            }
        }
        if tableView == lexicalMeaningTableView {
            guard let part = part(by: indexPath) else {
                return UITableViewCell()
            }
            if let part = part as? NameInfo {
                let identifier = String(describing: NameTableViewCell.self)
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                    as! NameTableViewCell
                cell.title = part.string
                return cell
            }
            if let part = part as? DefinitionInfo {
                let identifier = String(describing: DefinitionTableViewCell.self)
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                    as! DefinitionTableViewCell
                cell.title = part.string
                return cell
            }
            if let part = part as? LexicalMeaningInfo {
                let identifier = String(describing: LexicalMeaningTableViewCell.self)
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                    as! LexicalMeaningTableViewCell
                cell.delegate = self
                cell.title = part.string
                cell.attributedText = part.attributedString
                return cell
            }
            if let part = part as? LexicalExample {
                let identifier = String(describing: ExampleBrownTableViewCell.self)
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                    as! ExampleBrownTableViewCell
                cell.delegate = self
                cell.isCanPlay = part.isCanPlay
                cell.setup(word: nil, text: part.string)
                return cell
            }
            if let part = part as? FromExample {
                let identifier = String(describing: ExampleBlueTableViewCell.self)
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                    as! ExampleBlueTableViewCell
                cell.delegate = self
                cell.isCanPlay = part.isCanPlay
                cell.setup(word: textA, text: part.string)
                return cell
            }
            if let part = part as? ToExample {
                let identifier = String(describing: ExampleGrayTableViewCell.self)
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                    as! ExampleGrayTableViewCell
                cell.delegate = self
                cell.isCanPlay = part.isCanPlay
                cell.setup(word: textB, text: part.string)
                return cell
            }
            if let part = part as? Header {
                let identifier = String(describing: HeaderTableViewCell.self)
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                    as! HeaderTableViewCell
                cell.title = part.string
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension TranslationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if row < autocompletes.count {
            textA = autocompletes[row]
        }
        translationModel.enter(nil)
        asyncAfter(0.2) { [weak self] in
            guard let self = self else {
                return
            }
            self.dismissInputTextViewA()
        }
    }
}

extension TranslationViewController: ExampleTableViewCellDelegate {
    
    func exampleTableViewCell(_ exampleTableViewCell: ExampleTableViewCell, didPlay button: UIButton) {
        let indexPath = lexicalMeaningTableView.indexPath(for: exampleTableViewCell)
        guard let part = part(by: indexPath) else {
            return
        }
        var parameters = translationModel.languages
        parameters["text"] = part as? Stringable ?? ""
        if let part = part as? LexicalExample {
            // let event: Event = button.isSelected ? .clickStopSpeakLexicalMeaning : .clickSpeakLexicalMeaning
            // Analytics.track(.translation, event, parameters)
            translationModel.play(part.string, language: .a) { button.isSelected = $0 }
        }
        if let part = part as? FromExample {
            // let event: Event = button.isSelected ? .clickStopSpeakTatoebaWordMeaning : .clickSpeakTatoebaWordMeaning
            // Analytics.track(.translation, event, parameters)
            translationModel.play(part.string, language: .a) { button.isSelected = $0 }
        }
        if let part = part as? ToExample {
            // let event: Event = button.isSelected ? .clickStopSpeakTatoebaWordMeaning : .clickSpeakTatoebaWordMeaning
            // Analytics.track(.translation, event, parameters)
            translationModel.play(part.string, language: .b) { button.isSelected = $0 }
        }
    }
}

extension TranslationViewController: LexicalMeaningTableViewCellDelegate {
    
    func lexicalMeaningTableViewCell(_ lexicalMeaningTableViewCell: LexicalMeaningTableViewCell, didSelectWordAt index: Int) {
        let indexPath = lexicalMeaningTableView.indexPath(for: lexicalMeaningTableViewCell)
        if let part = part(by: indexPath) as? LexicalMeaningInfo, let words = part.words {
            if index < words.count {
                let word = words[index]
                var parameters = translationModel.languages
                parameters["text"] = word
                // Analytics.track(.translation, .clickWordMeaningLink, parameters)
                textA = word
                scrollUp()
                translationModel.translate()
            }
        }
    }
}

extension TranslationViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == textViewA {
            let y = -scrollView.contentOffset.y
            placeholderLabel.transform = CGAffineTransform(translationX: 0.0, y: y)
        }
    }
}

extension TranslationViewController: BannerViewDelegate {
    
    func bannerViewDidTouchUpInside(_ bannerView: BannerView) {
        translationModel.showPurchasesViewController()
    }
}

extension TranslationViewController: Scrollable {
    
    func scrollUp(animated: Bool = true) {
        let offset = CGPoint(x: 0.0, y: -top)
        scrollView.setContentOffset(offset, animated: animated)
    }
}

extension TranslationViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: ["com.adobe.pdf"]) || session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        for item in session.items {
            let provider = item.itemProvider
            if provider.hasItemConformingToTypeIdentifier("com.adobe.pdf") {
                DispatchQueue.global(qos: .background).async {
                    provider.loadFileRepresentation(forTypeIdentifier: "com.adobe.pdf") { url, error in
                        if error != nil {
                            return
                        }
                        if let url = url {
                            DispatchQueue.main.async { [weak self] in
                                self?.translationModel.translateDocument(with: url)
                            }
                        }
                    }
                }
            }
            if provider.canLoadObject(ofClass: UIImage.self) {
                DispatchQueue.global(qos: .background).async {
                    provider.loadObject(ofClass: UIImage.self) { object, error in
                        if error != nil {
                            return
                        }
                        if let image = object as? UIImage {
                            DispatchQueue.main.async { [weak self] in
                                self?.translationModel.showPhotoViewController(with: image)
                            }
                        }
                    }
                }
            }
        }
    }
}

class AutocompleteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
}

private extension UIViewController {
    
    func asyncAfter(_ time: Double, _ block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) { block() }
    }
}

private extension String {
    
    var onlyOneWord: String? {
        if count < 16, rangeOfCharacter(from: .newlines) == nil {
            let array = split(separator: " ")
            if array.count == 1 {
                return String(array.first!)
            }
        }
        return nil
    }
}

private extension Bool {
    
    var alpha: CGFloat { self ? 0.0 : 1.0 }
}

extension UIToolbar {
    
    static func tranlation(target: Any?, cancel: Selector, translate: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        let cancel = UIBarButtonItem(
            title: "_loc_cancel".localizable,
            style: .plain,
            target: target,
            action: cancel
        )
        let translate = UIBarButtonItem(
            title: "_loc_translate".localizable,
            style: .plain,
            target: target,
            action: translate
        )
        let space = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        cancel.tintColor = UIColor(named: "r_main_button")
        translate.tintColor = UIColor(named: "r_janna_blue")
        toolbar.items = [cancel, space, translate]
        toolbar.sizeToFit()
        return toolbar
    }
}
