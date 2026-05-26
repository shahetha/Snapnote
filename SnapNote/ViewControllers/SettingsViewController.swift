import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var defaultCategorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var currentSettingsLabel: UILabel!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var darkModeLabel: UILabel!
    
    var categories: [String] = ["Work", "Personal"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Set up segments
        defaultCategorySegmentedControl.removeAllSegments()
        for (index, category) in categories.enumerated() {
            defaultCategorySegmentedControl.insertSegment(withTitle: category, at: index, animated: false)
        }
        
        // Load the saved default category index
        let savedCategoryIndex = UserDefaults.standard.integer(forKey: "defaultCategoryIndex")
        defaultCategorySegmentedControl.selectedSegmentIndex = savedCategoryIndex < categories.count ? savedCategoryIndex : 0
        
        // Update current settings label
        updateCurrentSettingsLabel()
        
        // Set up dark mode switch based on current state
        setupDarkModeSwitch()
    }
    
    private func updateCurrentSettingsLabel() {
        let defaultCategory = categories[defaultCategorySegmentedControl.selectedSegmentIndex]
        currentSettingsLabel.text = "Default Category"
    }
    
    private func setupDarkModeSwitch() {
        // Check if dark mode is currently enabled
        let isDarkModeEnabled = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        darkModeSwitch.isOn = isDarkModeEnabled
        
        // Apply the current theme
        updateAppTheme(isDarkMode: isDarkModeEnabled)
    }
    
    private func updateAppTheme(isDarkMode: Bool) {
        // Save the setting
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkModeEnabled")
        
        // Update the app appearance
        if #available(iOS 13.0, *) {
            let appDelegate = UIApplication.shared.windows.first
            if isDarkMode {
                appDelegate?.overrideUserInterfaceStyle = .dark
            } else {
                appDelegate?.overrideUserInterfaceStyle = .light
            }
        }
    }
    
    private func saveDefaultCategory() {
        let selectedIndex = defaultCategorySegmentedControl.selectedSegmentIndex
        UserDefaults.standard.set(selectedIndex, forKey: "defaultCategoryIndex")
        UserDefaults.standard.set(categories[selectedIndex], forKey: "defaultCategory")
        
        // Update the display
        updateCurrentSettingsLabel()
    }
    
    // MARK: - Actions
    @IBAction func defaultCategoryChanged(_ sender: UISegmentedControl) {
        saveDefaultCategory()
        
        // Provide feedback
        let selectedCategory = categories[sender.selectedSegmentIndex]
        let alert = UIAlertController(title: "Default Category Changed", 
                                    message: "New default category: \(selectedCategory)",
                                 preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func darkModeToggled(_ sender: UISwitch) {
        let isDarkMode = sender.isOn
        updateAppTheme(isDarkMode: isDarkMode)
        
        // Optional: Show feedback
        let message = isDarkMode ? "Dark mode enabled" : "Light mode enabled"
        let alert = UIAlertController(title: "Theme Changed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
