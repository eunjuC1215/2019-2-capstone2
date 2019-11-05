//
//  MainViewController.swift
//  HyoJa-iOS
//
//  Created by Jeongho on 2019/11/04.
//  Copyright © 2019 eomjeongho. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    // MARK: @IBOUTLET
    @IBOutlet var seatNo: UITextView!
    @IBOutlet var timer: UITextView!
    @IBOutlet var seatReserve: UIButton!
    @IBOutlet var QRscaner: UIButton!
    @IBOutlet var reserveCancle: UIButton!
    @IBOutlet var reserveExtension: UIButton!
    @IBOutlet var Logout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        seatReserve.layer.cornerRadius = 10
        QRscaner.layer.cornerRadius = 10
        reserveCancle.layer.cornerRadius = 10
        reserveExtension.layer.cornerRadius = 10
        Logout.layer.cornerRadius = 10
    }
    
    // MARK: @IBAction
    @IBAction func Logout(_ sender: UIButton){
        UserDefaults.standard.removeObject(forKey: "id")
        UserDefaults.standard.removeObject(forKey: "pw")
        let loginPage = self.storyboard?.instantiateViewController(identifier: "Login")
        loginPage?.modalPresentationStyle = .fullScreen
        self.present(loginPage!, animated: true, completion: nil)
    }

}
