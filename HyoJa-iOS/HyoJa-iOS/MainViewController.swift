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
    @IBOutlet weak var SeatNo: UILabel!
    @IBOutlet var timeDown: UILabel!
    @IBOutlet var seatReserve: UIButton!
    @IBOutlet var QRscaner: UIButton!
    @IBOutlet var reserveCancle: UIButton!
    @IBOutlet var reserveExtension: UIButton!
    @IBOutlet var Logout: UIButton!
    
    // MARK: Var
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        seatReserve.layer.cornerRadius = 10
        QRscaner.layer.cornerRadius = 10
        reserveCancle.layer.cornerRadius = 10
        reserveExtension.layer.cornerRadius = 10
        Logout.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.SeatNo.text = String(UserDefaults.standard.string(forKey: "seat_no") ?? "--" )
    }
    
    // MARK: @IBAction
    @IBAction func Reserve(_ sender: UIButton){
        let isReserved = SeatNo.text
        if(isReserved != "--"){
            let alert = UIAlertController(title: "예약 실패", message: "예약 되어 있습니다.", preferredStyle: UIAlertController.Style.alert)
            let cancle = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel)
            alert.addAction(cancle)
            self.present(alert, animated: false)
        }
        else{
            let reservePage = self.storyboard?.instantiateViewController(identifier: "Reserve")
            reservePage?.modalPresentationStyle = .fullScreen
            self.present(reservePage!, animated: true, completion: nil)
        }
    }
    
    @IBAction func QRscan(_ sender: UIButton){
        let isReserved = SeatNo.text
        if(isReserved != "--"){
            let alert = UIAlertController(title: "예약 확인 실패", message: "예약을 먼저 하세요", preferredStyle: UIAlertController.Style.alert)
            let cancle = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel)
            alert.addAction(cancle)
            self.present(alert, animated: false)
        }
        else{
            let qrscanPage = self.storyboard?.instantiateViewController(identifier: "QRScan")
            self.present(qrscanPage!, animated: true, completion: nil)
        }
    }
    
    @IBAction func ReserveCancle(_ sender: UIButton){
        let isReserved = SeatNo.text
        if(isReserved == "--"){
            let alert = UIAlertController(title: "좌석 반납 실패", message: "예약을 먼저 하세요", preferredStyle: UIAlertController.Style.alert)
            let cancle = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel)
            alert.addAction(cancle)
            self.present(alert, animated: false)
        }
        else{
            cancle()
        }
    }
    
    @IBAction func ReserveExtension(_ sender: UIButton){
        let isReserved = SeatNo.text
        if(isReserved == "--"){
            let alert = UIAlertController(title: "좌석 연장 실패", message: "예약을 먼저 하세요", preferredStyle: UIAlertController.Style.alert)
            let cancle = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel)
            alert.addAction(cancle)
            self.present(alert, animated: false)
        }
    }
    
    @IBAction func Logout(_ sender: UIButton){
        UserDefaults.standard.removeObject(forKey: "id")
        UserDefaults.standard.removeObject(forKey: "pw")
        let loginPage = self.storyboard?.instantiateViewController(identifier: "Login")
        loginPage?.modalPresentationStyle = .fullScreen
        self.present(loginPage!, animated: true, completion: nil)
    }
    
    func cancle(){
        let alert = UIAlertController(title: "반납 하시겠습니까?", message: "", preferredStyle: UIAlertController.Style.alert)
        let enter = UIAlertAction(title:"반납", style: UIAlertAction.Style.default){
            (action) in
            var student_id = ""
            if let id = UserDefaults.standard.string(forKey: "id"){
                student_id = id
            }
            
            self.seat_reserve_request("http://13.124.28.135/reserve.php", student_no: student_id ,seat_no: "NULL"
                , option: "0")
            UserDefaults.standard.set("--", forKey: "seat_no")
            self.viewWillAppear(true)
        }
        let cancle = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel)
        alert.addAction(cancle)
        alert.addAction(enter)
        self.present(alert, animated: false)
    }
    
    // MARK: Server Request
    func seat_reserve_request(_ url:String, student_no:String, seat_no:String, option:String){
        var done: Bool! = false
        let url:NSURL = NSURL(string: url)!
        let session = URLSession.shared

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"

        let paramString = "student_no="+student_no+"&seat_no="+seat_no+"&reserve_opt="+option
        request.httpBody = paramString.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in

            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                 print(error?.localizedDescription ?? "No data")
                return
            }

            if let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            {
                if(dataString as String == "Success"){
                    done = true
                }
            }
        }
        
        task.resume()
        repeat {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        } while !done
    }
    
}
