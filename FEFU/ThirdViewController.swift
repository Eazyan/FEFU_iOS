// ThirdViewController.swift

import UIKit

class ThirdViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Заполните все поля")
            return
        }
        
        if isValidLogin(username: username, password: password) {
            // Navigate to Profile screen
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let profileVC = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
            navigationController?.setViewControllers([profileVC], animated: true)

        } else {
            showAlert(message: "Неправильный логин или пароль")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func isValidLogin(username: String, password: String) -> Bool {
        if let savedUserData = UserDefaults.standard.data(forKey: "registeredUser") {
            let decoder = JSONDecoder()
            if let user = try? decoder.decode(User.self, from: savedUserData) {
                return user.username == username && user.password == password
            }
        }
        return false
    }
}
