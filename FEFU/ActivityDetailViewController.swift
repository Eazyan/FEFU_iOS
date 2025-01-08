// ActivityDetailViewController.swift

import UIKit

class ActivityDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var navName: UINavigationItem!
    
    // MARK: - Properties
    var activity: Activity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        guard let activity = activity else { return }
        
        // Set navigation title
        navName.title = activity.type
        
        // Configure UI elements
        iconImageView.image = UIImage(systemName: activity.iconName)
        typeLabel.text = activity.type
        distanceLabel.text = activity.distance
        timeLabel.text = activity.time
        timestampLabel.text = formattedDate(activity.date)
    }
    
    // MARK: - Helper Methods
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
