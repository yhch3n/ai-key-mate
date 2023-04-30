//
//  KeyboardViewController.swift
//  AIKeyMate
//
//  Created by yihandogs on 2023/4/9.
//

import UIKit

class KeyboardViewController: UIInputViewController, UITextViewDelegate {

    @IBOutlet var nextKeyboardButton: UIButton!
    private let containerView = UIView()
    private let sendButton = UIButton(type: .system)
    private let inputScrollView = UITextView()
    private let gptResScrollView = UIScrollView()
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .system)
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        // Set the desired height for your keyboard extension
        self.view.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 1).isActive = true
        
        setupContainerView()
        setupButton()
        setupInputScrollView()
        setupGptResScrollView()
        setupConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.

        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])

        super.viewDidLoad()
    }
    
    private func setupContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        view.addSubview(containerView)
    }
    
    private func setupButton() {
        sendButton.setTitle("Send to ChatGPT!", for: .normal)
        sendButton.setTitleColor(.systemMint, for: .normal)
        sendButton.backgroundColor = .white
        sendButton.layer.cornerRadius = 5
        sendButton.layer.borderWidth = 1
        sendButton.layer.borderColor = UIColor.systemMint.cgColor
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendButton)
    }
    
    private func setupInputScrollView() {
        inputScrollView.backgroundColor = .white
        inputScrollView.layer.cornerRadius = 5
        inputScrollView.layer.borderWidth = 1
        inputScrollView.layer.borderColor = UIColor.systemGray5.cgColor
        inputScrollView.translatesAutoresizingMaskIntoConstraints = false

        // Set the text field's delegate to the view controller.
        inputScrollView.delegate = self
        inputScrollView.setPlaceholder(text: "Copy/Paste text here...")
        inputScrollView.backgroundColor = .white
        
        containerView.addSubview(inputScrollView)
    }

    private func setupGptResScrollView() {
        gptResScrollView.backgroundColor = .systemGray5
        gptResScrollView.layer.cornerRadius = 5
        gptResScrollView.layer.borderWidth = 1
        gptResScrollView.layer.borderColor = UIColor.systemGray5.cgColor
        
        gptResScrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(gptResScrollView)
    }
    
    private func setupConstraints() {

        NSLayoutConstraint.activate([
            // ContainerView constraints
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            // Button constraints
            sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.15),
            sendButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.95),
            sendButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),

            // ScrollView constraints
            inputScrollView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            inputScrollView.bottomAnchor.constraint(equalTo: sendButton.topAnchor, constant: -5),
            inputScrollView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.35),
            inputScrollView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.95),
            
            gptResScrollView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            gptResScrollView.bottomAnchor.constraint(equalTo: inputScrollView.topAnchor, constant: -5),
            gptResScrollView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.35),
            gptResScrollView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.95)
        ])
    }

}

extension UITextView {
    func setPlaceholder(text: String) {
        self.text = text
        self.textColor = UIColor.lightGray
    }

    func removePlaceholder() {
        self.text = nil
        self.textColor = UIColor.black
    }
}

// Add UITextViewDelegate methods
extension KeyboardViewController {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.removePlaceholder()
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.setPlaceholder(text: "Copy/Paste text here...")
        }
    }
}
