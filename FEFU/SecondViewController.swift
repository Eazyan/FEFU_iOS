// SecondViewController.swift

import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var genderButton: UIButton!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
    }
    
    @IBAction func genderButtonTapped(_ sender: UIButton) {
        showGenderSelection()
    }
    
    func showGenderSelection() {
        // Create Action Sheet
        let alert = UIAlertController(title: "Выберите пол", message: nil, preferredStyle: .actionSheet)
        
        // Add options
        alert.addAction(UIAlertAction(title: "Мужской", style: .default, handler: { _ in
            self.genderButton.setTitle("Мужской", for: .normal)
        }))
        alert.addAction(UIAlertAction(title: "Женский", style: .default, handler: { _ in
            self.genderButton.setTitle("Женский", for: .normal)
        }))
        
        // Cancel button
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        // Present Action Sheet
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty,
              let nickname = nicknameTextField.text, !nickname.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Заполните все поля")
            return
        }
        
        // Check passwords match
        guard password == confirmPassword else {
            showAlert(message: "Пароли не совпадают")
            return
        }
        
        // Create user
        let gender = genderButton.title(for: .normal) ?? "Не указано"
        let user = User(username: username, nickname: nickname, password: password, gender: gender)
        
        // Save user to UserDefaults
        saveUser(user)
        
        // Navigate to Profile screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
        navigationController?.setViewControllers([profileVC], animated: true)
    }

    private func saveUser(_ user: User) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: "registeredUser")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
