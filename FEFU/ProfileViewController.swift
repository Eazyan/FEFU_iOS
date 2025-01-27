//import UIKit
//import SwiftUI
//
//class ProfileViewController: UIViewController {
//
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var logOutButton: UIButton!
//
//    // Данные для таблицы
//    let sectionTitles = ["Данные профиля", "Пол"]  // Заголовки секций
//    let profileData = [
//        ["Логин": "Value", "Имя или никнейм": "Value", "Пароль": "hehprostoypass88"]
//    ]
//    let genderData = [["Пол": "Мужской"]]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//    }
//
//    @IBAction func logOutAction(_ sender: UIButton) {
//        // Логика выхода из профиля
//        print("Выйти из профиля")
//    }
//}
//
//extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
//
//    // Количество секций
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return sectionTitles.count // Количество секций
//    }
//    
//    // Количество строк в каждой секции
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section {
//        case 0:
//            return profileData[0].count // Количество данных в секции "Данные профиля"
//        case 1:
//            return genderData[0].count // Количество данных в секции "Пол"
//        default:
//            return 0
//        }
//    }
//
//    // Заголовок для секции
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sectionTitles[section] // Название секции
//    }
//
//    // Настройка ячеек для каждой строки
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
//        
//        switch indexPath.section {
//        case 0:
//            let data = profileData[0] // Данные из первой секции
//            let key = Array(data.keys)[indexPath.row]
//            cell.textLabel?.text = key
//            cell.detailTextLabel?.text = data[key]
//        case 1:
//            let data = genderData[0] // Данные из секции пола
//            let key = Array(data.keys)[indexPath.row]
//            cell.textLabel?.text = key
//            cell.detailTextLabel?.text = data[key]
//        default:
//            break
//        }
//        
//        return cell
//    }
//}
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var chartView: UIView!  // Для добавления графика

    // Данные для таблицы
    let sectionTitles = ["Данные профиля", "Пол"]  // Заголовки секций
    var profileData: [String: String] = [:] // Массив для данных профиля
    var genderData: [String: String] = [:]   // Массив для данных о поле
    var activities: [Activity] = []           // Данные о тренировках для графика

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Загружаем данные о пользователе и тренировках из хранилища
        loadUser()
        loadActivities()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Настройка графика
        setupChart()
    }

    @IBAction func logOutAction(_ sender: UIButton) {
        // Логика выхода из профиля
        print("Выйти из профиля")
    }

    // Загружаем данные о пользователе из UserDefaults
    private func loadUser() {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()
        
        if let savedData = defaults.data(forKey: "registeredUser"),
           let decodedUser = try? decoder.decode(User.self, from: savedData) {
            // Сохраняем данные пользователя
            profileData["Логин"] = decodedUser.username
            profileData["Имя или никнейм"] = decodedUser.nickname
            profileData["Пароль"] = decodedUser.password
            genderData["Пол"] = decodedUser.gender
        }
    }

    // Загружаем данные о тренировках из UserDefaults
    private func loadActivities() {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let savedData = defaults.data(forKey: "savedActivities"),
           let decodedActivities = try? decoder.decode([Activity].self, from: savedData) {
            activities = decodedActivities
        }
    }

    // Настройка графика
    private func setupChart() {
        let chart = LineChartView(frame: CGRect(x: 0, y: 0, width: chartView.bounds.width, height: 200))
        
        // Преобразуем данные о дистанции в метры
        let distances = activities.map { Double($0.distance.split(separator: " ")[0]) ?? 0 }
        let dates = activities.map { $0.date }
        
        // Устанавливаем данные для графика
        chart.data = distances
        chart.labels = dates.map { formatDate($0) }
        
        chartView.addSubview(chart)
    }

    // Форматирование даты для оси X
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

    // Количество секций
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    // Количество строк в каждой секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return profileData.count // Количество данных в секции "Данные профиля"
        case 1:
            return genderData.count // Количество данных в секции "Пол"
        default:
            return 0
        }
    }

    // Заголовок для секции
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section] // Название секции
    }

    // Настройка ячеек для каждой строки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)

        switch indexPath.section {
        case 0:
            let key = Array(profileData.keys)[indexPath.row]
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = profileData[key]
        case 1:
            let key = Array(genderData.keys)[indexPath.row]
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = genderData[key]
        default:
            break
        }

        return cell
    }
}
