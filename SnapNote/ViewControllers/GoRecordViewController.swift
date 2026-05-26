import UIKit
import AVFoundation
import Speech

class GoRecordViewController: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var liveTranscriptionTextView: UITextView!
    
    var categories: [String] = ["Work", "Personal"]
    var isRecording = false
    
    private let speechRecognizer = SpeechRecognizer()
    private var lastTranscription: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Apply the default category setting when the view appears
        applyDefaultCategory()
    }
    
    private func applyDefaultCategory() {
        // Get the saved default category index
        let defaultCategoryIndex = UserDefaults.standard.integer(forKey: "defaultCategoryIndex")
        
        // Make sure it's a valid index
        if defaultCategoryIndex < categories.count {
            categorySegmentedControl.selectedSegmentIndex = defaultCategoryIndex
        }
    }
    
    private func setupUI() {
        categorySegmentedControl.removeAllSegments()
        for (index, category) in categories.enumerated() {
            categorySegmentedControl.insertSegment(withTitle: category, at: index, animated: false)
        }
        
        // Set to the default category from settings
        applyDefaultCategory()
        
        liveTranscriptionTextView.text = ""
        
        // Set initial status message
        statusLabel.text = "Press mic to start recording"
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        statusLabel.numberOfLines = 0 // Allow multiple lines
        statusLabel.lineBreakMode = .byWordWrapping

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular, scale: .large)
        let image = UIImage(systemName: "mic.circle", withConfiguration: symbolConfig)
        recordButton.setImage(image, for: .normal)
        recordButton.setTitle("", for: .normal)
        recordButton.tintColor = .systemBlue
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        isRecording.toggle()
        
        if isRecording {
            startRecording()
        } else {
            stopRecording()
        }
        
        updateRecordButtonState()
    }
    
    private func startRecording() {
        lastTranscription = ""
        // Initial recording state
        statusLabel.text = "Listening..."
        
        speechRecognizer.record { [weak self] transcribedText in
            guard let self = self else { return }
            self.lastTranscription = transcribedText
            
            // Update status label with only the 5-6 most recent words
            DispatchQueue.main.async {
                if self.isRecording {
                    if transcribedText.isEmpty {
                        self.statusLabel.text = "Listening..."
                    } else {
                        // Get the most recent words
                        let words = transcribedText.components(separatedBy: " ")
                        let recentWords = words.suffix(6).joined(separator: " ")
                        self.statusLabel.text = recentWords
                    }
                }
                self.liveTranscriptionTextView.text = transcribedText
            }
        }
    }
    
    private func stopRecording() {
        speechRecognizer.stopRecording()
        
        // Update status label with a shorter version of the final transcript
        DispatchQueue.main.async {
            if self.lastTranscription.isEmpty {
                self.statusLabel.text = "No speech detected"
            } else {
                // Get the last few words to show in the status label
                let words = self.lastTranscription.components(separatedBy: " ")
                if words.count > 6 {
                    let endWords = words.suffix(6).joined(separator: " ")
                    self.statusLabel.text = "Recorded: ..."+endWords
                } else {
                    self.statusLabel.text = "Recorded: " + self.lastTranscription
                }
            }
            
            if self.liveTranscriptionTextView.text.isEmpty {
                self.liveTranscriptionTextView.text = self.lastTranscription
            }
        }
    }
    
    private func updateRecordButtonState() {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular, scale: .large)
        let imageName = isRecording ? "mic.circle.fill" : "mic.circle"
        let image = UIImage(systemName: imageName, withConfiguration: symbolConfig)

        recordButton.setImage(image, for: .normal)
        recordButton.setTitle("", for: .normal)
        recordButton.tintColor = isRecording ? .systemGreen : .systemBlue
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard !lastTranscription.isEmpty else { return }
        
        // Stop recording if it's in progress
        if isRecording {
            isRecording = false
            stopRecording()
            updateRecordButtonState()
        }
        
        let selectedCategoryIndex = categorySegmentedControl.selectedSegmentIndex
        let category = categories[selectedCategoryIndex]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: Date())
        
        let newNote = GoNote(text: lastTranscription, category: category, date: dateString)
        NotesStore.shared.addNote(newNote)
        
        // Reset UI
        DispatchQueue.main.async {
            self.statusLabel.text = "Press mic to start recording"
            self.liveTranscriptionTextView.text = ""
        }
        lastTranscription = ""
        
        // Reset to default category
        applyDefaultCategory()
    }
    
    @IBAction func discardButtonTapped(_ sender: UIButton) {
        // Stop recording if it's in progress
        if isRecording {
            isRecording = false
            speechRecognizer.stopRecording()
            updateRecordButtonState()
        }
        
        // Reset UI
        DispatchQueue.main.async {
            self.statusLabel.text = "Press mic to start recording"
            self.liveTranscriptionTextView.text = ""
        }
        lastTranscription = ""
        
        // Reset to default category
        applyDefaultCategory()
    }
    
    @IBAction func categorySegmentChanged(_ sender: UISegmentedControl) {}
}
