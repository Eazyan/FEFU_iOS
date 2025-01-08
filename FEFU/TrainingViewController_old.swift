//// TrainingViewController.swift
//
//import UIKit
//import MapKit
//import CoreLocation
//
//class TrainingViewController: UIViewController {
//    
//    // MARK: - Outlets
//    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var infoView: UIView!
//    @IBOutlet weak var distanceLabel: UILabel!
//    @IBOutlet weak var timeLabel: UILabel!
//    @IBOutlet weak var pauseButton: UIButton!
//    @IBOutlet weak var finishButton: UIButton!
//    @IBOutlet weak var cyclingButton: UIButton!
//    @IBOutlet weak var runningButton: UIButton!
//    @IBOutlet weak var startButton: UIButton!
//    
//    // MARK: - Properties
//    let locationManager = CLLocationManager()
//    var isTracking = false
//    var isPaused = false
//    var selectedTrainingType: Activity.TrainingType = .cycling
//    var startTime: Date?
//    var timer: Timer?
//    var totalDistance: Double = 0.0
//    var previousLocation: CLLocation?
//    var routeCoordinates: [CLLocationCoordinate2D] = []
//    weak var delegate: TrainingViewControllerDelegate?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupLocationManager()
//        setupUI()
//    }
//    
//    // MARK: - Setup Methods
//    func setupLocationManager() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//    }
//    
//    func setupUI() {
//        // Инициализация начального состояния UI
//        distanceLabel.text = "Расстояние: 0.00 км"
//        timeLabel.text = "Время: 00:00:00"
//        pauseButton.isHidden = true
//        finishButton.isHidden = true
//        startButton.isHidden = false
//        
//        // Настройка MapView
//        mapView.showsUserLocation = true
//        mapView.userTrackingMode = .follow
//        mapView.delegate = self
//        
//        // Выбор типа тренировки по умолчанию
//        selectTrainingType(type: .cycling)
//    }
//    
//    // MARK: - Actions
//    
//    @IBAction func cyclingButtonTapped(_ sender: UIButton) {
//        selectTrainingType(type: .cycling)
//    }
//    
//    @IBAction func runningButtonTapped(_ sender: UIButton) {
//        selectTrainingType(type: .running)
//    }
//    
//    @IBAction func startButtonTapped(_ sender: UIButton) {
//        if !isTracking {
//            startTraining()
//        }
//    }
//    
//    @IBAction func pauseButtonTapped(_ sender: UIButton) {
//        if isTracking && !isPaused {
//            pauseTraining()
//        } else if isTracking && isPaused {
//            resumeTraining()
//        }
//    }
//    
//    @IBAction func finishButtonTapped(_ sender: UIButton) {
//        finishTraining()
//    }
//    
//    // MARK: - Training Methods
//    
//    func selectTrainingType(type: Activity.TrainingType) {
//        selectedTrainingType = type
//        
//        // Обновление UI кнопок
//        cyclingButton.layer.borderColor = type == .cycling ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
//        cyclingButton.layer.borderWidth = type == .cycling ? 2.0 : 0.0
//        
//        runningButton.layer.borderColor = type == .running ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
//        runningButton.layer.borderWidth = type == .running ? 2.0 : 0.0
//    }
//    
//    func startTraining() {
//        let status = CLLocationManager.authorizationStatus()
//        if status == .authorizedWhenInUse || status == .authorizedAlways {
//            locationManager.startUpdatingLocation()
//            isTracking = true
//            isPaused = false
//            startTime = Date()
//            routeCoordinates = []
//            totalDistance = 0.0
//            
//            // Обновление UI
//            pauseButton.isHidden = false
//            finishButton.isHidden = false
//            startButton.isHidden = true
//            
//            // Запуск таймера
//            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTrainingInfo), userInfo: nil, repeats: true)
//        } else {
//            locationManager.requestWhenInUseAuthorization()
//        }
//    }
//    
//    func pauseTraining() {
//        isPaused = true
//        locationManager.stopUpdatingLocation()
//        timer?.invalidate()
//        pauseButton.setTitle("Продолжить", for: .normal)
//    }
//    
//    func resumeTraining() {
//        isPaused = false
//        locationManager.startUpdatingLocation()
//        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTrainingInfo), userInfo: nil, repeats: true)
//        pauseButton.setTitle("Пауза", for: .normal)
//    }
//    
//    func finishTraining() {
//        guard isTracking else { return }
//        
//        isTracking = false
//        isPaused = false
//        locationManager.stopUpdatingLocation()
//        timer?.invalidate()
//        
//        // Сохранение данных тренировки
//        saveTraining()
//        
//        // Обновление UI
//        pauseButton.isHidden = true
//        finishButton.isHidden = true
//        startButton.isHidden = false
//    }
//    
//    @objc func updateTrainingInfo() {
//        guard let startTime = startTime else { return }
//        
//        let elapsedTime = Date().timeIntervalSince(startTime)
//        let hours = Int(elapsedTime) / 3600
//        let minutes = (Int(elapsedTime) % 3600) / 60
//        let seconds = Int(elapsedTime) % 60
//        
//        timeLabel.text = String(format: "Время: %02d:%02d:%02d", hours, minutes, seconds)
//        distanceLabel.text = String(format: "Расстояние: %.2f км", totalDistance)
//    }
//    
//    func saveTraining() {
//        guard let startTime = startTime else { return }
//        
//        let newActivity = Activity(
//            distance: totalDistance,
//            time: Date().timeIntervalSince(startTime),
//            type: selectedTrainingType,
//            date: startTime,
//            routeCoordinates: routeCoordinates
//        )
//        
//        delegate?.didFinishTraining(activity: newActivity)
//    }
//}
//
//// MARK: - CLLocationManagerDelegate
//extension TrainingViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        switch status {
//        case .authorizedWhenInUse, .authorizedAlways:
//            if isTracking && !isPaused {
//                locationManager.startUpdatingLocation()
//            }
//        case .denied, .restricted:
//            // Показать предупреждение
//            let alert = UIAlertController(title: "Доступ к местоположению запрещён", message: "Пожалуйста, разрешите доступ к местоположению в настройках устройства для отслеживания тренировки.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            present(alert, animated: true, completion: nil)
//        default:
//            break
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard isTracking && !isPaused else { return }
//        
//        for location in locations {
//            if let previousLocation = previousLocation {
//                let distance = location.distance(from: previousLocation) // в метрах
//                totalDistance += distance / 1000.0 // перевод в километры
//                addRoute(from: previousLocation.coordinate, to: location.coordinate)
//            }
//            self.previousLocation = location
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Ошибка получения местоположения: \(error.localizedDescription)")
//    }
//}
//
//// MARK: - MKMapViewDelegate
//extension TrainingViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if let polyline = overlay as? MKPolyline {
//            let renderer = MKPolylineRenderer(polyline: polyline)
//            renderer.strokeColor = selectedTrainingType == .cycling ? .systemBlue : .systemRed
//            renderer.lineWidth = 4.0
//            return renderer
//        }
//        return MKOverlayRenderer(overlay: overlay)
//    }
//    
//    // Рисование маршрута
//    func addRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
//        let coordinates = [start, end]
//        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
//        mapView.addOverlay(polyline)
//        routeCoordinates.append(contentsOf: coordinates)
//    }
//}
