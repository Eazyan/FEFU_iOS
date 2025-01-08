//
//  FourthViewController.swift
//  FEFU
//
//  Created by Антон Лёгкий on 05.01.2025.
//

import UIKit

class ProfileViewController: UIViewController {

    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    private func loadUser() -> User? {
        if let savedUserData = UserDefaults.standard.data(forKey: "registeredUser") {
            let decoder = JSONDecoder()
            if let user = try? decoder.decode(User.self, from: savedUserData) {
                return user
            }
        }
        return nil
    }
    
    

}
