import UIKit

class FirstViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        // Переход на экран регистрации
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        navigationController?.pushViewController(secondVC, animated: true)
    }
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Переход на экран логина
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let thirdVC = storyboard.instantiateViewController(withIdentifier: "ThirdViewController") as! ThirdViewController
        navigationController?.pushViewController(thirdVC, animated: true)
    }
}
