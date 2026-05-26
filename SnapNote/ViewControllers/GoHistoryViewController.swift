import UIKit

class GoHistoryViewController: UITableViewController {
    
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    
    var categories: [String] = ["Work", "Personal"]
    var filteredNotes: [GoNote] = []  // Filtered notes shown in table view

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 200
        setupSegmentedControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterNotes()
    }

    private func setupSegmentedControl() {
        categorySegmentedControl.removeAllSegments()
        for (index, category) in categories.enumerated() {
            categorySegmentedControl.insertSegment(withTitle: category, at: index, animated: false)
        }
        categorySegmentedControl.selectedSegmentIndex = 0
    }

    private func filterNotes() {
        let selectedCategory = categories[categorySegmentedControl.selectedSegmentIndex]
        filteredNotes = NotesStore.shared.notes.filter { $0.category == selectedCategory }
        print("[filterNotes] Showing \(filteredNotes.count) notes for \(selectedCategory)")
        tableView.reloadData()
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryTableViewCell else {
            return UITableViewCell()
        }

        let note = filteredNotes[indexPath.row]
        cell.noteLabel.text = note.text
        cell.categoryLabel.text = "[\(note.category)]"
        cell.dateLabel.text = note.date

        cell.editButton.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row

        cell.editButton.addTarget(self, action: #selector(editNoteTapped(_:)), for: .touchUpInside)
        cell.deleteButton.addTarget(self, action: #selector(deleteNoteTapped(_:)), for: .touchUpInside)

        return cell
    }

    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedNote = filteredNotes[indexPath.row]
        print("[GoHistoryVC] Selected note: \(selectedNote.text)")
        
        // Create a strong reference to the note before passing
        let noteToPass = GoNote(text: selectedNote.text, 
                               category: selectedNote.category, 
                               date: selectedNote.date)
        
        // Instantiate the detail view controller
        guard let detailVC = storyboard?.instantiateViewController(identifier: "NoteDetailViewController") as? NoteDetailViewController else {
            print("[GoHistoryVC] Error: Could not instantiate NoteDetailViewController")
            return
        }
        
        // Set the note property first
        detailVC.note = noteToPass
        print("[GoHistoryVC] Passed note to DetailVC with text: \(noteToPass.text)")
        print("[GoHistoryVC] Note category: \(noteToPass.category), date: \(noteToPass.date)")
        
        // Use manual state preservation to ensure the note is available
        let userInfo = ["noteText": noteToPass.text, 
                         "noteCategory": noteToPass.category,
                         "noteDate": noteToPass.date]
        NotificationCenter.default.post(name: NSNotification.Name("NoteDetailDataAvailable"), 
                                       object: nil, 
                                       userInfo: userInfo)
        
        // Navigate to the detail view
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // MARK: - Segmented Control Change

    @IBAction func categorySegmentChanged(_ sender: UISegmentedControl) {
        filterNotes()
    }

    // MARK: - Actions

    @objc func editNoteTapped(_ sender: UIButton) {
        let row = sender.tag
        let selectedNote = filteredNotes[row]

        guard let originalIndex = NotesStore.shared.notes.firstIndex(where: {
            $0.text == selectedNote.text && $0.date == selectedNote.date && $0.category == selectedNote.category
        }) else {
            return
        }

        let alert = UIAlertController(title: "Edit Note", message: "Modify your note text below:", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = selectedNote.text
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let updatedText = alert.textFields?.first?.text, !updatedText.isEmpty {
                var updatedNote = selectedNote
                updatedNote.text = updatedText
                NotesStore.shared.updateNote(at: originalIndex, with: updatedNote)
                self.filterNotes()
                print("[editNoteTapped] Updated note at \(originalIndex)")
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    @objc func deleteNoteTapped(_ sender: UIButton) {
        let row = sender.tag
        let selectedNote = filteredNotes[row]

        guard let originalIndex = NotesStore.shared.notes.firstIndex(where: {
            $0.text == selectedNote.text && $0.date == selectedNote.date && $0.category == selectedNote.category
        }) else {
            return
        }

        let alert = UIAlertController(title: "Delete Note", message: "Are you sure you want to delete this note?", preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            NotesStore.shared.deleteNote(at: originalIndex)
            self.filterNotes()
            print("[deleteNoteTapped] Deleted note at \(originalIndex)")
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}
