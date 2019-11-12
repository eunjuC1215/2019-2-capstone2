//
//  MainViewController.swift
//  HyoJa-iOS
//
//  Created by Jeongho on 2019/11/04.
//  Copyright © 2019 eomjeongho. All rights reserved.
//

import UIKit
import MobileCoreServices

class MainViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // MARK: @IBOUTLET
    @IBOutlet var seatNo: UITextView!
    @IBOutlet var timer: UITextView!
    @IBOutlet var seatReserve: UIButton!
    @IBOutlet var QRscaner: UIButton!
    //@IBOutlet var reserveCancle: UIButton!
    @IBOutlet var reserveExtension: UIButton!
    @IBOutlet var Logout: UIButton!
    
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var captureImage: UIImage!
    var flagImageSave = false
    
    @IBAction func CaptureImageFromCamera(_ sender:UIButton){
        if(UIImagePickerController.isSourceTypeAvailable(.camera)){
            flagImageSave = true
            
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            present(imagePicker,animated: true, completion: nil)
        } else {
            myAlert("Camera inaccessible", message: "Application cannot access the camera.")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func myAlert(_ title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        seatReserve.layer.cornerRadius = 10
        QRscaner.layer.cornerRadius = 10
        //reserveCancle.layer.cornerRadius = 10
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
