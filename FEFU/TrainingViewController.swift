// TrainingViewController.swift

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
    
    private var selectedTrainingType: String = "Велосипед" // По умолчанию
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
        setupTrainingTypeButtons()
        
        // Начальное состояние UI
        trainingInfoView.isHidden = true
        pauseButton.isHidden = true
        finishButton.isHidden = true
        
        typeLabel.text = selectedTrainingType
        distanceLabel.text = "0.0 км"
        timeLabel.text = "00:00:00"
        
        // Настройка кнопок
        pauseButton.layer.cornerRadius = pauseButton.frame.height / 2
        finishButton.layer.cornerRadius = finishButton.frame.height / 2
        
        pauseButton.backgroundColor = .systemGray5
        pauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
    }
    
    private func setupTrainingTypeButtons() {
        for subview in trainingTypeSelectionView.subviews {
            if let button = subview as? UIButton {
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.clear.cgColor
                button.layer.cornerRadius = 10
                button.imageView?.contentMode = .scaleAspectFit
                button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
                button.addTarget(self, action: #selector(trainingTypeButtonTapped(_:)), for: .touchUpInside)
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
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
    
    @objc private func trainingTypeButtonTapped(_ sender: UIButton) {
        selectedTrainingType = (sender.tag == 0) ? "Велосипед" : "Бег"
        typeLabel.text = selectedTrainingType
        
        for subview in trainingTypeSelectionView.subviews {
            if let button = subview as? UIButton {
                button.layer.borderColor = (button == sender) ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
                
                // Анимация парения
                if button == sender {
                    UIView.animate(withDuration: 0.2, animations: {
                        button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    })
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        button.transform = .identity
                    })
                }
            }
        }
    }
    
    // MARK: - Tracking Methods
    
    private func startTracking() {
        isTracking = true
        isPaused = false
        startTime = Date()
        locationManager.startUpdatingLocation()
        
        trainingInfoView.isHidden = false
        pauseButton.isHidden = false
        finishButton.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.trainingTypeView.alpha = 0
        }) { _ in
            self.trainingTypeView.isHidden = true
        }
        
        if let polyline = polyline {
            mapView.removeOverlay(polyline)
        }
        routeCoordinates.removeAll()
        distance = 0.0
        distanceLabel.text = "0.0 км"
        timeLabel.text = "00:00:00"
        
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
            type: selectedTrainingType,
            timestamp: formattedDate(Date()),
            iconName: (selectedTrainingType == "Велосипед") ? "bicycle.circle.fill" : "figure.walk.circle",
            date: Date()
        )
        
        delegate?.didFinishTraining(activity: activity)
        navigationController?.popViewController(animated: true)
        
        selectedTrainingType = "Велосипед"
        typeLabel.text = selectedTrainingType
        trainingTypeSelectionView.isHidden = false
        trainingTypeSelectionView.alpha = 1.0
        
        for subview in trainingTypeSelectionView.subviews {
            if let button = subview as? UIButton {
                button.layer.borderColor = (button.title(for: .normal) == selectedTrainingType) ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
            }
        }
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
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            let alert = UIAlertController(title: "Доступ к геолокации запрещен", message: "Пожалуйста, разрешите доступ к геолокации в настройках устройства.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking, !isPaused, let location = locations.last else { return }
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
        routeCoordinates.append(location.coordinate)
        
        if let previousLocation = previousLocation {
            let delta = location.distance(from: previousLocation) / 1000.0
            distance += delta
            distanceLabel.text = String(format: "%.1f км", distance)
        }
        previousLocation = location
        
        if routeCoordinates.count > 1 {
            if let polyline = polyline {
                mapView.removeOverlay(polyline)
            }
            polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
            mapView.addOverlay(polyline!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Ошибка GPS", message: "Не удалось определить ваше местоположение. Пожалуйста, проверьте настройки устройства.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - MKMapViewDelegate

extension TrainingViewController{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = (selectedTrainingType == "Велосипед") ? .systemBlue : .systemRed
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
