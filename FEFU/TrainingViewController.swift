import UIKit
import MapKit
import CoreLocation

protocol TrainingViewControllerDelegate: AnyObject {
    func didFinishTraining(activity: Activity)
}

class TrainingViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trainingTypeSelectionView: UIView!
    @IBOutlet weak var trainingInfoView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var trainingTypeView: UIView!
    
    // MARK: - Properties
    weak var delegate: TrainingViewControllerDelegate?
    
    private let locationManager = CLLocationManager()
    private var isTracking = false
    private var isPaused = false
    private var timer: Timer?
    private var startTime: Date?
    private var elapsedTime: TimeInterval = 0
    private var distance: Double = 0.0
    private var previousLocation: CLLocation?
    private var routeCoordinates: [CLLocationCoordinate2D] = []
    private var polyline: MKPolyline?
    
    private var selectedTrainingType: TrainingType = .велосипед // По умолчанию
    private var pausedTime: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Скрытие навигационного бара, если он есть
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupUI()
        setupLocationManager()
        setupMapView()
        checkLocationAuthorization()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Настройка выбора типа тренировки
        setupTrainingTypeButtons()
        
        // Начальное состояние UI
        trainingInfoView.isHidden = true
        pauseButton.isHidden = true
        finishButton.isHidden = true
        
        typeLabel.text = selectedTrainingType.description
        distanceLabel.text = "0.0 км"
        timeLabel.text = "00:00:00"
        
        // Настройка кнопок
        pauseButton.layer.cornerRadius = pauseButton.frame.height / 2
        finishButton.layer.cornerRadius = finishButton.frame.height / 2
        
        // Настройка начального цвета паузы
        pauseButton.backgroundColor = .systemGray5
        pauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
    }
    
    private func setupTrainingTypeButtons() {
        for subview in trainingTypeSelectionView.subviews {
            if let button = subview as? UIButton {
                button.layer.borderWidth = 2
                button.layer.cornerRadius = 10
                button.layer.borderColor = UIColor.clear.cgColor
                button.addTarget(self, action: #selector(trainingTypeButtonTapped(_:)), for: .touchUpInside)
            }
        }
        highlightSelectedButton() // Выделяем текущий выбранный тип
    }
    
    @objc private func trainingTypeButtonTapped(_ sender: UIButton) {
        guard let type = TrainingType(rawValue: sender.tag) else { return }
        selectedTrainingType = type
        typeLabel.text = selectedTrainingType.description
        highlightSelectedButton() // Обновляем выделение
    }
    
    private func highlightSelectedButton() {
        for subview in trainingTypeSelectionView.subviews {
            if let button = subview as? UIButton {
                button.layer.borderColor = (button.tag == selectedTrainingType.rawValue) ? UIColor.systemGreen.cgColor : UIColor.clear.cgColor
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10 // Обновление каждые 10 метров
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            let alert = UIAlertController(title: "Доступ к геолокации запрещен", message: "Пожалуйста, разрешите доступ к геолокации в настройках устройства.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        @unknown default:
            break
        }
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        startTracking()
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        togglePause()
    }
    
    @IBAction func finishButtonTapped(_ sender: UIButton) {
        finishTraining()
    }
    
    // MARK: - Tracking Methods
    
    private func startTracking() {
        isTracking = true
        isPaused = false
        startTime = Date()
        locationManager.startUpdatingLocation()
        
        // Настройка UI
        trainingInfoView.isHidden = false
        pauseButton.isHidden = false
        finishButton.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.trainingTypeView.alpha = 0
        }) { _ in
            self.trainingTypeView.isHidden = true
        }
        
        // Сброс данных
        routeCoordinates.removeAll()
        distance = 0.0
        distanceLabel.text = "0.0 км"
        timeLabel.text = "00:00:00"
        
        // Запуск таймера
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateElapsedTime), userInfo: nil, repeats: true)
    }
    
    private func togglePause() {
        if isPaused {
            isPaused = false
            locationManager.startUpdatingLocation()
            startTime = Date().addingTimeInterval(-pausedTime)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateElapsedTime), userInfo: nil, repeats: true)
            pauseButton.backgroundColor = .systemGray5
            pauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
        } else {
            isPaused = true
            locationManager.stopUpdatingLocation()
            timer?.invalidate()
            pausedTime = elapsedTime
            pauseButton.backgroundColor = .systemYellow
            pauseButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        }
    }
    
    private func finishTraining() {
        isTracking = false
        isPaused = false
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        
        let activity = Activity(
            distance: String(format: "%.1f км", distance),
            time: formatTime(timeInterval: elapsedTime),
            type: selectedTrainingType.description,
            timestamp: formattedDate(Date()),
            iconName: (selectedTrainingType == .велосипед) ? "bicycle.circle.fill" : "figure.walk.circle",
            date: Date()
        )
        
        delegate?.didFinishTraining(activity: activity)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime)
        timeLabel.text = formatTime(timeInterval: elapsedTime)
    }
    
    private func formatTime(timeInterval: TimeInterval) -> String {
        let ti = Int(timeInterval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = ti / 3600
        return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - CLLocationManagerDelegate

extension TrainingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking, !isPaused, let location = locations.last else { return }
        
        if let previousLocation = previousLocation {
            let delta = location.distance(from: previousLocation) / 1000.0
            distance += delta
            distanceLabel.text = String(format: "%.1f км", distance)
        }
        previousLocation = location
    }
}

// MARK: - TrainingType Enum
private enum TrainingType: Int {
    case велосипед = 0
    case бег = 1

    var description: String {
        switch self {
        case .велосипед: return "Велосипед"
        case .бег: return "Бег"
        }
    }
}
