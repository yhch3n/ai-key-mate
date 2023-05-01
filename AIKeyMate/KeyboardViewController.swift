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
    private let buttonStackView = UIStackView()
    private let sendButton = UIButton(type: .system)
    private let copyButton = UIButton(type: .system)
    private let pasteButton = UIButton(type: .system)
    private let inputScrollView = UITextView()
    private let clearButton = UIButton(type: .custom)
    private let gptResScrollView = UIScrollView()
    private let gptResLabel = UILabel()

    private let promptLabel = UILabel()
    private let pickerView = UILabel()
    private let floatingContainerView = UIView()
    private let promptsTableView = UITableView()
    var prompts: [PromptOption] = []
    var selectedPromptValue: String?

    private var isLoadingPromptOptions = false
    private var isLoadingAPIResponse = false

    private let apiViewModel = APIViewModel()
    
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
        self.view.heightAnchor.constraint(equalToConstant: 350).isActive = true
        
        pickerView.text = "Loading..."
        apiViewModel.loadPromptOptions { [weak self] promptOptions in
            // Update UI or perform other actions with the prompt options
            DispatchQueue.main.async {
                self?.prompts = promptOptions
                self?.promptsTableView.reloadData()
                self?.isLoadingPromptOptions = false
                self?.pickerView.text = " Select a prompt."
            }
        }

        setupContainerView()
        setupButtons()
        setupButtonStackView()
        setupInputScrollView()
        setupClearButton()
        setupGptResScrollView()

        setupDropDownMenu()
        setupFloatingContainerView()
        setupPromptsTableView()

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

    private func setupButtonStackView() {
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 5
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(buttonStackView)

        // Add buttons to the stack view
        buttonStackView.addArrangedSubview(copyButton)
        buttonStackView.addArrangedSubview(pasteButton)
        buttonStackView.addArrangedSubview(sendButton)
    }
    
    private func setupButtons() {
        sendButton.setTitle("Gen!", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.titleLabel?.font = .systemFont(ofSize: 14)
        sendButton.backgroundColor = .systemMint
        sendButton.setTitleColor(UIColor.systemGray5, for: .disabled)
        sendButton.layer.cornerRadius = 5
        sendButton.layer.borderWidth = 1
        sendButton.layer.borderColor = UIColor.systemMint.cgColor
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)

        // Configure and add copyButton
        copyButton.setTitle("Copy Response", for: .normal)
        copyButton.setTitleColor(.systemMint, for: .normal)
        copyButton.titleLabel?.font = .systemFont(ofSize: 14)
        copyButton.backgroundColor = .white
        copyButton.layer.cornerRadius = 5
        copyButton.layer.borderWidth = 1
        copyButton.layer.borderColor = UIColor.systemMint.cgColor
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)

        // Configure and add pasteButton
        pasteButton.setTitle("Paste Text", for: .normal)
        pasteButton.setTitleColor(.systemMint, for: .normal)
        pasteButton.titleLabel?.font = .systemFont(ofSize: 14)
        pasteButton.backgroundColor = .white
        pasteButton.layer.cornerRadius = 5
        pasteButton.layer.borderWidth = 1
        pasteButton.layer.borderColor = UIColor.systemMint.cgColor
        pasteButton.translatesAutoresizingMaskIntoConstraints = false
        pasteButton.addTarget(self, action: #selector(pasteButtonTapped), for: .touchUpInside)
    }

    private func createCustomAlertView() -> UIView {
        let customAlertView = UIView()
        customAlertView.backgroundColor = UIColor.white
        customAlertView.layer.cornerRadius = 10
        customAlertView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Full Access Required"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        customAlertView.addSubview(titleLabel)

        let messageLabel = UILabel()
        messageLabel.text = "Please go to Settings -> General -> Keyboard -> Keyboards and enable Full Access for this keyboard to use the copy/paste feature."
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        customAlertView.addSubview(messageLabel)

        let okButton = UIButton(type: .system)
        okButton.setTitle("OK", for: .normal)
        okButton.addTarget(self, action: #selector(dismissFullAccessAlert), for: .touchUpInside)
        okButton.translatesAutoresizingMaskIntoConstraints = false
        customAlertView.addSubview(okButton)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: customAlertView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: customAlertView.topAnchor, constant: 8),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: customAlertView.leadingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: customAlertView.trailingAnchor, constant: -8),

            okButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            okButton.centerXAnchor.constraint(equalTo: customAlertView.centerXAnchor),
            okButton.bottomAnchor.constraint(equalTo: customAlertView.bottomAnchor, constant: -8)
        ])

        return customAlertView
    }
    
    private func showFullAccessAlert() {
        let customAlertView = createCustomAlertView()
        customAlertView.tag = 999 // Assign a tag for easy dismissal
        containerView.addSubview(customAlertView)

        NSLayoutConstraint.activate([
            customAlertView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            customAlertView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            customAlertView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8)
        ])
    }

    @objc func dismissFullAccessAlert() {
        if let customAlertView = containerView.viewWithTag(999) {
            customAlertView.removeFromSuperview()
        }
    }

    private func setupDropDownMenu() {
        // Setup promptLabel
        promptLabel.text = "Prompt: "
        promptLabel.textColor = .systemGray
        promptLabel.font = UIFont.systemFont(ofSize: 14)
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(promptLabel)

        // Setup pickerView
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = .white
        pickerView.layer.cornerRadius = 5
        pickerView.layer.borderWidth = 1
        pickerView.layer.borderColor = UIColor.systemGray5.cgColor
        pickerView.text = " Select a prompt"
        pickerView.textColor = .systemGray
        pickerView.font = UIFont.systemFont(ofSize: 14)
        pickerView.isUserInteractionEnabled = true
        pickerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(togglePromptsTableView)))
        containerView.addSubview(pickerView)
    }
    private func setupFloatingContainerView() {
        floatingContainerView.isHidden = true
        floatingContainerView.backgroundColor = UIColor.yellow
        floatingContainerView.layer.borderColor = UIColor.gray.cgColor
        floatingContainerView.layer.borderWidth = 1
        floatingContainerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(floatingContainerView)
    }
    private func setupPromptsTableView() {
        promptsTableView.isHidden = true
        promptsTableView.delegate = self
        promptsTableView.dataSource = self
        promptsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        promptsTableView.translatesAutoresizingMaskIntoConstraints = false
        floatingContainerView.addSubview(promptsTableView)
    }
    @objc private func togglePromptsTableView() {
        guard !isLoadingPromptOptions else { return }
        promptsTableView.isHidden.toggle()
        floatingContainerView.isHidden.toggle()
    }

    @objc private func sendButtonTapped() {
        guard !isLoadingAPIResponse else { return }

        isLoadingAPIResponse = true
        sendButton.isEnabled = false
        gptResLabel.text = "Loading..."

        let inputText = inputScrollView.text

        let combinedText: String
        if let selectedPromptValue = selectedPromptValue {
            combinedText = selectedPromptValue + " " + (inputText ?? "")
        } else {
            combinedText = inputText ?? ""
        }

        // Use the combinedText to query the OpenAI API
        apiViewModel.sendChatQuery(content: combinedText) { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoadingAPIResponse = false
                self?.sendButton.isEnabled = true
                self?.gptResLabel.text = response
            }
        }
    }

    @objc private func pasteButtonTapped() {
        if self.hasFullAccess {
            let pasteboard = UIPasteboard.general
            if let copiedText = pasteboard.string {
                inputScrollView.insertText(copiedText)
            }
        } else {
            showFullAccessAlert()
        }
    }

    @objc func copyButtonTapped() {
        if self.hasFullAccess {
            if let responseText = gptResLabel.text {
                UIPasteboard.general.string = responseText
            }
        } else {
            showFullAccessAlert()
        }
    }

    private func setupInputScrollView() {
        inputScrollView.backgroundColor = .white
        inputScrollView.layer.cornerRadius = 5
        inputScrollView.layer.borderWidth = 1
        inputScrollView.layer.borderColor = UIColor.systemGray5.cgColor
        inputScrollView.translatesAutoresizingMaskIntoConstraints = false

        // Set the text field's delegate to the view controller.
        inputScrollView.delegate = self
        inputScrollView.setPlaceholder(text: "Paste text here...")
        inputScrollView.backgroundColor = .white
        inputScrollView.textAlignment = .left
        inputScrollView.font = UIFont.systemFont(ofSize: 14)
        containerView.addSubview(inputScrollView)
        inputScrollView.addSubview(clearButton)

        setupResLabel()
    }

    private func setupClearButton() {
        clearButton.setTitle("X", for: .normal)
        clearButton.setTitleColor(.systemMint, for: .normal)
        clearButton.backgroundColor = .white
        clearButton.layer.cornerRadius = 10
        clearButton.clipsToBounds = true
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
    }

    @objc private func clearButtonTapped() {
        inputScrollView.text = ""
    }

    private func setupGptResScrollView() {
        gptResScrollView.backgroundColor = .systemGray5
        gptResScrollView.layer.cornerRadius = 5
        gptResScrollView.layer.borderWidth = 1
        gptResScrollView.layer.borderColor = UIColor.systemGray5.cgColor
        gptResScrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(gptResScrollView)
    }

    private func setupResLabel() {
        gptResLabel.translatesAutoresizingMaskIntoConstraints = false
        gptResLabel.numberOfLines = 0
        gptResLabel.lineBreakMode = .byWordWrapping
        gptResLabel.textAlignment = .left
        gptResLabel.font = UIFont.systemFont(ofSize: 14)
        gptResLabel.textColor = inputScrollView.textColor
        gptResScrollView.addSubview(gptResLabel)
    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([
            // ContainerView constraints
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            // Add constraints for buttonStackView
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            buttonStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            buttonStackView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.1),
            buttonStackView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.95),

            // Add constraints for the prompts dropdown menu
            promptLabel.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -5),
            promptLabel.leadingAnchor.constraint(equalTo: gptResScrollView.leadingAnchor),
            promptLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.18),
            promptLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.13),

            pickerView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -5),
            pickerView.leadingAnchor.constraint(equalTo: promptLabel.trailingAnchor, constant: -0.5),
            pickerView.trailingAnchor.constraint(equalTo: buttonStackView.trailingAnchor),
            pickerView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.13),

            floatingContainerView.bottomAnchor.constraint(equalTo: pickerView.topAnchor, constant: -5),
            floatingContainerView.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor),
            floatingContainerView.trailingAnchor.constraint(equalTo: buttonStackView.trailingAnchor),
            floatingContainerView.heightAnchor.constraint(equalToConstant: 150),

            promptsTableView.topAnchor.constraint(equalTo: floatingContainerView.topAnchor),
            promptsTableView.leadingAnchor.constraint(equalTo: floatingContainerView.leadingAnchor),
            promptsTableView.trailingAnchor.constraint(equalTo: floatingContainerView.trailingAnchor),
            promptsTableView.bottomAnchor.constraint(equalTo: floatingContainerView.bottomAnchor),

            // ScrollView constraints
            inputScrollView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            inputScrollView.bottomAnchor.constraint(equalTo: pickerView.topAnchor, constant: -5),
            inputScrollView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3),
            inputScrollView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.95),
            
            clearButton.widthAnchor.constraint(equalToConstant: 20),
            clearButton.heightAnchor.constraint(equalToConstant: 20),
            clearButton.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor, constant: -8),
            clearButton.bottomAnchor.constraint(equalTo: pickerView.topAnchor, constant: -8),

            gptResScrollView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            gptResScrollView.bottomAnchor.constraint(equalTo: inputScrollView.topAnchor, constant: -5),
            gptResScrollView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3),
            gptResScrollView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.95),

            gptResLabel.widthAnchor.constraint(equalTo: gptResScrollView.widthAnchor),
            gptResLabel.topAnchor.constraint(equalTo: gptResScrollView.topAnchor),
            gptResLabel.leadingAnchor.constraint(equalTo: gptResScrollView.leadingAnchor),
            gptResLabel.trailingAnchor.constraint(equalTo: gptResScrollView.trailingAnchor),
            gptResLabel.bottomAnchor.constraint(equalTo: gptResScrollView.bottomAnchor)
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
            textView.setPlaceholder(text: "Paste text here...")
        }
    }
}

extension KeyboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prompts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = prompts[indexPath.row].key
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.textColor = .systemGray
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPromptOption = prompts[indexPath.row]
        pickerView.text = " " + selectedPromptOption.key
        selectedPromptValue = selectedPromptOption.value

        tableView.deselectRow(at: indexPath, animated: true)
        togglePromptsTableView()
    }
}
