//import UIKit
//
//class ActivityViewController: UIViewController {
//    
//    // MARK: - Outlets
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var emptyStateView: UIView!
//    @IBOutlet weak var startButton: UIButton!
//    
//    // MARK: - Properties
//    var activities: [Activity] = []
//    var groupedActivities: [String: [Activity]] = [:]
//    var sortedSections: [String] = []
//    
//    // Date Formatter
//    let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "ru_RU")
//        formatter.dateFormat = "LLLL yyyy"
//        return formatter
//    }()
//    
//    // Calendar
//    let calendar = Calendar.current
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Настройка TableView
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.separatorStyle = .none
//        
//        // Загрузка данных
//        loadActivities()
//        groupActivitiesByDate()
//        updateUI()
//    }
//    
//    // MARK: - Actions
//    
//    @IBAction func startButtonTapped(_ sender: UIButton) {
//        let newActivity = Activity(
//            distance: "5 км",
//            time: "30 минут",
//            type: "Бег",
//            timestamp: "", // Будет обновлено позже
//            iconName: "figure.walk.circle",
//            date: Date()
//        )
//        activities.append(newActivity)
//        
//        // Сохранение активностей
//        saveActivities()
//        
//        // Группировка и обновление UI
//        groupActivitiesByDate()
//        updateUI()
//        tableView.reloadData()
//    }
//    
//    // MARK: - Helper Methods
//    
//    private func groupActivitiesByDate() {
//        let todayStart = calendar.startOfDay(for: Date())
//        let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart)!
//        
//        groupedActivities = Dictionary(grouping: activities, by: { activity in
//            let activityDate = activity.date
//            if activityDate >= todayStart {
//                return "Сегодня"
//            } else if activityDate >= yesterdayStart {
//                return "Вчера"
//            } else {
//                return dateFormatter.string(from: activityDate).capitalized
//            }
//        })
//        
//        // Сортировка активностей внутри групп по дате (сначала новые)
//        for (key, value) in groupedActivities {
//            groupedActivities[key] = value.sorted(by: { $0.date > $1.date })
//        }
//        
//        // Сортировка секций по дате (сначала новые)
//        sortedSections = groupedActivities.keys.sorted { key1, key2 in
//            let date1 = sectionDate(for: key1)
//            let date2 = sectionDate(for: key2)
//            return date1 > date2
//        }
//    }
//    
//    private func sectionDate(for key: String) -> Date {
//        if key == "Сегодня" {
//            return calendar.startOfDay(for: Date())
//        } else if key == "Вчера" {
//            return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!
//        } else {
//            return dateFormatter.date(from: key) ?? Date.distantPast
//        }
//    }
//    
//    private func formattedTimeSince(date: Date) -> String {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.locale = Locale(identifier: "ru_RU")
//        formatter.unitsStyle = .full
//        
//        let now = Date()
//        let secondsDifference = now.timeIntervalSince(date)
//        
//        if secondsDifference < 60 {
//            return "Только что"
//        } else {
//            return formatter.localizedString(for: date, relativeTo: now)
//        }
//    }
//    
//    private func saveActivities() {
//        let defaults = UserDefaults.standard
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        
//        if let encoded = try? encoder.encode(activities) {
//            defaults.set(encoded, forKey: "savedActivities")
//        }
//    }
//    
//    private func loadActivities() {
//        let defaults = UserDefaults.standard
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//        
//        if let savedData = defaults.data(forKey: "savedActivities"),
//           let decodedActivities = try? decoder.decode([Activity].self, from: savedData) {
//            activities = decodedActivities
//        } else {
//            // Добавление примерных активностей
//            activities = [
//                Activity(distance: "14.32 км", time: "2 часа 46 минут", type: "Велосипед", timestamp: "14 часов назад", iconName: "bicycle.circle.fill", date: calendar.date(byAdding: .day, value: -1, to: Date())!),
//                Activity(distance: "12.5 км", time: "1 час 35 минут", type: "Бег", timestamp: "Вчера", iconName: "figure.walk.circle", date: calendar.date(byAdding: .month, value: -8, to: Date())!),
//                Activity(distance: "5.0 км", time: "45 минут", type: "Прогулка", timestamp: "Только что", iconName: "figure.walk.circle", date: Date())
//            ]
//            saveActivities()
//        }
//    }
//    
//    private func updateUI() {
//        if activities.isEmpty {
//            emptyStateView.isHidden = false
//            tableView.isHidden = true
//        } else {
//            emptyStateView.isHidden = true
//            tableView.isHidden = false
//            tableView.reloadData()
//        }
//    }
//    
//    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowActivityDetail",
//           let destinationVC = segue.destination as? ActivityDetailViewController,
//           let activity = sender as? Activity {
//            destinationVC.activity = activity
//        }
//    }
//}
//
//extension ActivityViewController: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return sortedSections.count
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let key = sortedSections[section]
//        return groupedActivities[key]?.count ?? 0
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as? ActivityTableViewCell else {
//            return UITableViewCell()
//        }
//        
//        let key = sortedSections[indexPath.section]
//        if let activity = groupedActivities[key]?[indexPath.row] {
//            cell.distanceLabel.text = activity.distance
//            cell.timeLabel.text = activity.time
//            cell.typeLabel.text = activity.type
//            cell.timestampLabel.text = formattedTimeSince(date: activity.date)
//            cell.iconImageView.image = UIImage(systemName: activity.iconName)
//        }
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 130
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.systemGroupedBackground
//        
//        let titleLabel = UILabel()
//        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
//        titleLabel.textColor = .darkGray
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        let key = sortedSections[section]
//        titleLabel.text = key
//        
//        headerView.addSubview(titleLabel)
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
//            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
//        ])
//        
//        return headerView
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
//    
//    // MARK: - Did Select Row
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let key = sortedSections[indexPath.section]
//        if let activity = groupedActivities[key]?[indexPath.row] {
//            print("Selected Activity: \(activity.type)") // Для отладки
//            performSegue(withIdentifier: "ShowActivityDetail", sender: activity)
//        }
//        
//        // Снимаем выделение с ячейки
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//}

// ActivityViewController.swift

import UIKit

class ActivityViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: - Properties
    var activities: [Activity] = []
    var groupedActivities: [String: [Activity]] = [:]
    var sortedSections: [String] = []
    
    // Date Formatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()
    
    // Calendar
    let calendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        // Load data
        loadActivities()
        groupActivitiesByDate()
        updateUI()
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        navigateToTraining()
    }
    
    // MARK: - Navigation
    
    private func navigateToTraining() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let trainingVC = storyboard.instantiateViewController(withIdentifier: "TrainingViewController") as? TrainingViewController else {
            print("Не удалось найти TrainingViewController в Storyboard")
            return
        }
        
        trainingVC.delegate = self
        navigationController?.pushViewController(trainingVC, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func groupActivitiesByDate() {
        let todayStart = calendar.startOfDay(for: Date())
        let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart)!
        
        groupedActivities = Dictionary(grouping: activities, by: { activity in
            let activityDate = activity.date
            if activityDate >= todayStart {
                return "Сегодня"
            } else if activityDate >= yesterdayStart {
                return "Вчера"
            } else {
                return dateFormatter.string(from: activityDate).capitalized
            }
        })
        
        // Sort activities within groups by date (newest first)
        for (key, value) in groupedActivities {
            groupedActivities[key] = value.sorted(by: { $0.date > $1.date })
        }
        
        // Sort sections by date (newest first)
        sortedSections = groupedActivities.keys.sorted { key1, key2 in
            let date1 = sectionDate(for: key1)
            let date2 = sectionDate(for: key2)
            return date1 > date2
        }
    }
    
    private func sectionDate(for key: String) -> Date {
        if key == "Сегодня" {
            return calendar.startOfDay(for: Date())
        } else if key == "Вчера" {
            return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!
        } else {
            return dateFormatter.date(from: key) ?? Date.distantPast
        }
    }
    
    private func formattedTimeSince(date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.unitsStyle = .full
        
        let now = Date()
        let secondsDifference = now.timeIntervalSince(date)
        
        if secondsDifference < 60 {
            return "Только что"
        } else {
            return formatter.localizedString(for: date, relativeTo: now)
        }
    }
    
    private func saveActivities() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        if let encoded = try? encoder.encode(activities) {
            defaults.set(encoded, forKey: "savedActivities")
        }
    }
    
    private func loadActivities() {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let savedData = defaults.data(forKey: "savedActivities"),
           let decodedActivities = try? decoder.decode([Activity].self, from: savedData) {
            activities = decodedActivities
        } else {
            // Add sample activities
            activities = [
                Activity(distance: "14.32 км", time: "2 часа 46 минут", type: "Велосипед", timestamp: "14 часов назад", iconName: "bicycle.circle.fill", date: calendar.date(byAdding: .day, value: -1, to: Date())!),
                Activity(distance: "12.5 км", time: "1 час 35 минут", type: "Бег", timestamp: "Вчера", iconName: "figure.walk.circle", date: calendar.date(byAdding: .month, value: -8, to: Date())!),
                Activity(distance: "5.0 км", time: "45 минут", type: "Прогулка", timestamp: "Только что", iconName: "figure.walk.circle", date: Date())
            ]
            saveActivities()
        }
    }
    
    private func updateUI() {
        if activities.isEmpty {
            emptyStateView.isHidden = false
            tableView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}

// MARK: - Navigation

extension ActivityViewController: TrainingViewControllerDelegate {
    func didFinishTraining(activity: Activity) {
        activities.append(activity)
        saveActivities()
        groupActivitiesByDate()
        updateUI()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ActivityViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sortedSections[section]
        return groupedActivities[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as? ActivityTableViewCell else {
            return UITableViewCell()
        }
        
        let key = sortedSections[indexPath.section]
        if let activity = groupedActivities[key]?[indexPath.row] {
            cell.distanceLabel.text = activity.distance
            cell.timeLabel.text = activity.time
            cell.typeLabel.text = activity.type
            cell.timestampLabel.text = formattedTimeSince(date: activity.date)
            cell.iconImageView.image = UIImage(systemName: activity.iconName)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemGroupedBackground
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let key = sortedSections[section]
        titleLabel.text = key
        
        headerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // MARK: - Did Select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = sortedSections[indexPath.section]
        if let activity = groupedActivities[key]?[indexPath.row] {
            print("Selected Activity: \(activity.type)") // For debugging
            performSegue(withIdentifier: "ShowActivityDetail", sender: activity)
        }
        
        // Deselect the cell
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowActivityDetail",
           let destinationVC = segue.destination as? ActivityDetailViewController,
           let activity = sender as? Activity {
            destinationVC.activity = activity
        }
    }
}
