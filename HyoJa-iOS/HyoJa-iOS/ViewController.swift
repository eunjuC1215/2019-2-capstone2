//
//  ViewController.swift
//  HyoJa-iOS
//
//  Created by Jeongho on 2019/11/04.
//  Copyright © 2019 eomjeongho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: IBOUTLET
    @IBOutlet var ID: UITextField!
    @IBOutlet var PW: UITextField!
    @IBOutlet var LoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ID.layer.cornerRadius = 10
        PW.layer.cornerRadius = 10
        LoginButton.layer.cornerRadius = 10
    }

    @IBAction func touchUpLoginButton(_ sender: UIButton){
        let mainPage = self.storyboard?.instantiateViewController(identifier: "Main")
        mainPage?.modalPresentationStyle = .fullScreen
        self.present(mainPage!, animated: true, completion: nil)
    }
}

