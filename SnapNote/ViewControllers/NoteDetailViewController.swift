//
//  NoteDetailViewController.swift
//  SnapNote
//
//  Created by Shahetha on 4/28/25.
//

import UIKit

// Custom UITextView subclass that prevents placeholder text
class NoPlaceholderTextView: UITextView {
    override var text: String! {
        get {
            return super.text
        }
        set {
            // Clear attributed text when setting plain text
            attributedText = nil
            super.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Clear any placeholder text from storyboard
        self.attributedText = nil
        self.text = ""
    }
}

class NoteDetailViewController: UIViewController {
    
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // Use a didSet to track when the note is set
    var note: GoNote? {
        didSet {
            print("[NoteDetailVC] Note property set: \(note?.text ?? "nil")")
            // If view is already loaded, update UI immediately
            if isViewLoaded {
                setupUI()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Note Details"
        
        print("[NoteDetailVC] viewDidLoad called, note: \(note?.text ?? "nil")")
        
        // Force clear any placeholder text immediately
        if let textView = noteTextView {
            textView.text = ""
        }
        
        // Register for the note data notification
        NotificationCenter.default.addObserver(self, 
                                             selector: #selector(handleNoteDataNotification(_:)), 
                                             name: NSNotification.Name("NoteDetailDataAvailable"), 
                                             object: nil)
        
        // If note is already set, set up UI
        if note != nil {
            setupUI()
        }
    }
    
    @objc private func handleNoteDataNotification(_ notification: Notification) {
        guard note == nil, 
              let userInfo = notification.userInfo,
              let text = userInfo["noteText"] as? String,
              let category = userInfo["noteCategory"] as? String,
              let date = userInfo["noteDate"] as? String else {
            return
        }
        
        // Reconstruct the note from notification data
        note = GoNote(text: text, category: category, date: date)
        print("[NoteDetailVC] Reconstructed note from notification: \(text)")
        setupUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        
        // Force redraw the text view after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.refreshTextView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTextView()
        
        // Direct emergency update to ensure content is displayed
        if let noteText = note?.text, !noteText.isEmpty {
            DispatchQueue.main.async {
                // Force direct update of the text view
                if let textView = self.noteTextView {
                    print("[NoteDetailVC] Emergency direct text update: \(noteText)")
                    textView.text = noteText
                    
                    // Create a label as a fallback if text view fails
                    if textView.text != noteText {
                        self.addFallbackLabel(with: noteText)
                    }
                } else {
                    // No text view, create a label
                    self.addFallbackLabel(with: noteText)
                }
            }
        }
    }
    
    private func refreshTextView() {
        guard let note = note, let textView = noteTextView else { return }
        
        // Try the most aggressive approach - replace the text view entirely
        if textView.text.contains("Lorem ipsum") || textView.text.contains("lorem ipsum") {
            print("[NoteDetailVC] Found lorem ipsum placeholder, replacing text view")
            replaceTextView(with: note.text)
            return
        }
        
        // Standard approach if no Lorem ipsum detected
        // Completely reset text view to force it to update
        textView.text = ""
        textView.attributedText = nil
        
        // Set the content again
        if !note.text.isEmpty {
            print("[NoteDetailVC] Setting text view content: \(note.text)")
            textView.text = note.text
        } else {
            textView.text = "(No content)"
        }
        
        // Force layout update
        textView.setNeedsLayout()
        textView.layoutIfNeeded()
    }
    
    private func replaceTextView(with content: String) {
        // Only proceed if we have a valid text view to reference for frame
        guard let originalTextView = noteTextView, let containerView = originalTextView.superview else {
            return
        }
        
        // Create a new text view with the same frame
        let newTextView = UITextView(frame: originalTextView.frame)
        newTextView.font = UIFont.systemFont(ofSize: 16)
        newTextView.backgroundColor = UIColor.systemBackground
        newTextView.isEditable = false
        newTextView.isSelectable = true
        newTextView.text = content
        
        // Set constraints to match the original
        newTextView.translatesAutoresizingMaskIntoConstraints = originalTextView.translatesAutoresizingMaskIntoConstraints
        
        // Replace the old text view with the new one
        containerView.addSubview(newTextView)
        originalTextView.removeFromSuperview()
        noteTextView = newTextView
        
        // If using auto layout, we need to add constraints
        if !newTextView.translatesAutoresizingMaskIntoConstraints {
            // Try to match constraints of the original text view
            for constraint in containerView.constraints {
                if constraint.firstItem === originalTextView {
                    containerView.addConstraint(NSLayoutConstraint(
                        item: newTextView,
                        attribute: constraint.firstAttribute,
                        relatedBy: constraint.relation,
                        toItem: constraint.secondItem,
                        attribute: constraint.secondAttribute,
                        multiplier: constraint.multiplier,
                        constant: constraint.constant
                    ))
                } else if constraint.secondItem === originalTextView {
                    containerView.addConstraint(NSLayoutConstraint(
                        item: constraint.firstItem as Any,
                        attribute: constraint.firstAttribute,
                        relatedBy: constraint.relation,
                        toItem: newTextView,
                        attribute: constraint.secondAttribute,
                        multiplier: constraint.multiplier,
                        constant: constraint.constant
                    ))
                }
            }
        }
        
        print("[NoteDetailVC] Created new text view with content: \(content)")
    }
    
    private func setupUI() {
        guard let note = note else {
            print("[NoteDetailVC] Error: note is nil")
            return
        }
        
        print("[NoteDetailVC] Setting up UI with note: \(note.text)")
        
        // Print out outlet status to debug
        if noteTextView == nil {
            print("[NoteDetailVC] Error: noteTextView outlet is nil")
        }
        if categoryLabel == nil {
            print("[NoteDetailVC] Error: categoryLabel outlet is nil")
        }
        if dateLabel == nil {
            print("[NoteDetailVC] Error: dateLabel outlet is nil")
        }
        
        if let textView = noteTextView {
            // Clear any placeholder text
            textView.text = ""
            textView.attributedText = nil
            
            // Configure text view appearance
            textView.isEditable = false
            textView.isSelectable = true
            textView.font = UIFont.systemFont(ofSize: 16)
            textView.backgroundColor = UIColor.systemBackground
            
            // Set the note text
            if !note.text.isEmpty {
                textView.text = note.text
                print("[NoteDetailVC] Set note text: \(note.text)")
            } else {
                textView.text = "(No text content)"
                print("[NoteDetailVC] Note text was empty")
            }
        }
        
        categoryLabel?.text = "Category: \(note.category)"
        dateLabel?.text = "Date: \(note.date)"
        
        print("[NoteDetailVC] UI setup complete")
    }
    
    private func addFallbackLabel(with text: String) {
        print("[NoteDetailVC] Creating fallback label with text: \(text)")
        
        // Create a label to show the content
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Add it to the view
        view.addSubview(label)
        
        // Center it in the view
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
