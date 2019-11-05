//
//  ViewController.swift
//  HyoJa-iOS
//
//  Created by Jeongho on 2019/11/04.
//  Copyright © 2019 eomjeongho. All rights reserved.
//

import UIKit
import CryptoSwift

class ViewController: UIViewController {

    // MARK: IBOUTLET
    @IBOutlet var ID: UITextField!
    @IBOutlet var PW: UITextField!
    @IBOutlet var LoginButton: UIButton!
    
    var isLogin: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ID.layer.cornerRadius = 10
        PW.layer.cornerRadius = 10
        LoginButton.layer.cornerRadius = 10
    }

    @IBAction func touchUpLoginButton(_ sender: UIButton){
        let key = "################################"
        let iv = "################"
        var cipher = ""
        do{
            let aes = try! AES(key: key.bytes, blockMode: CBC(iv: iv.bytes) , padding: .pkcs5)
            cipher = try aes.encrypt(Array(PW.text!.utf8)).toBase64()!
        }catch{}

        data_request("http://13.124.28.135/check.php", id: ID.text!, pw: cipher)
    }
    
    func data_request(_ url:String, id:String, pw:String)
    {
        let url:NSURL = NSURL(string: url)!
        let session = URLSession.shared

        var isLogin: Bool! = false
        var done: Bool! = false
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"

        let paramString = "id="+id+"&pw="+pw
        request.httpBody = paramString.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in

            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                 print(error?.localizedDescription ?? "No data")
                return
            }

            if var dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            {
                if(dataString as String == "Success"){
                    isLogin = true
                }
                done = true
            }
        }
        
        task.resume()
        
        repeat {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        } while !done
        
        if(isLogin){
            let mainPage = self.storyboard?.instantiateViewController(identifier: "Main")
            mainPage?.modalPresentationStyle = .fullScreen
            self.present(mainPage!, animated: true, completion: nil)
        }
    }

}
