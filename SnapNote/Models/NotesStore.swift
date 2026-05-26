import Foundation

class NotesStore {
    static let shared = NotesStore()
    private let notesKey = "notesKey"

    private(set) var notes: [GoNote] = []

    private init() {
        loadNotes()
    }

    func addNote(_ note: GoNote) {
        notes.append(note)
        saveNotes()
    }

    func updateNote(at index: Int, with newNote: GoNote) {
        guard notes.indices.contains(index) else { return }
        notes[index] = newNote
        saveNotes()
    }

    func deleteNote(at index: Int) {
        guard notes.indices.contains(index) else { return }
        notes.remove(at: index)
        saveNotes()
    }

    func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: notesKey)
            print("[NotesStore] Notes saved to UserDefaults")
        } catch {
            print("[NotesStore] Failed to save notes: \(error)")
        }
    }

    func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: notesKey) {
            do {
                notes = try JSONDecoder().decode([GoNote].self, from: data)
                print("[NotesStore] Notes loaded from UserDefaults")
            } catch {
                print("[NotesStore] Failed to load notes: \(error)")
                notes = []
            }
        } else {
            print("[NotesStore] No saved notes found.")
        }
    }
}
