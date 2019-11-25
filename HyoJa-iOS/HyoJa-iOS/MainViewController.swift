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
    
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var captureImage: UIImage!
    var flagImageSave = false
    
    
    var time = 0
    var timer = Timer()
    var startTimer = false
    var reserve_info : [String] = []
    var startTime = ""
    var state:String = "0"
    
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
        reserveCancle.layer.cornerRadius = 10
        reserveExtension.layer.cornerRadius = 10
        Logout.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.SeatNo.text = String(UserDefaults.standard.string(forKey: "seat_no") ?? "--" )
        self.state = UserDefaults.standard.string(forKey: "state") ?? "0"
        if(SeatNo.text != "--" && state == "1"){
            timeLimitStart()
        }
        else{
            timeLimitStop()
        }
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
    
    @IBAction func cancle(){
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
            self.timeLimitStop()
            self.time = 0
            self.viewWillAppear(true)
        }
        let cancle = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel)
        alert.addAction(cancle)
        alert.addAction(enter)
        self.present(alert, animated: false)
    }
    
    func timeLimitStart(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeLimit),
                                     userInfo:nil, repeats: true)
        var student_id = ""
        if let id = UserDefaults.standard.string(forKey: "id"){
            student_id = id
        }
        get_reserve_info("http://13.124.28.135/isReserve.php", student_no: student_id)
        
        let date = Date(timeIntervalSinceNow: 32400) //한국시간으로 변경
        print(date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        let dateString = dateFormatter.string(from: date)
        let now_time = dateString.components(separatedBy: ":")
        let now_min = Int(now_time[0])!
        let now_sec = Int(now_time[1])!
        print(now_min)
        print(now_sec)
        print(now_min*60+now_sec)
        
        let reserve_time = reserve_info[1]
        let start_time = reserve_time.components(separatedBy: " ")
        let start_min = Int(((start_time[1]).components(separatedBy: ":"))[1])!
        let start_sec = Int(((start_time[1]).components(separatedBy: ":"))[2])!
        print(start_min)
        print(start_sec)
        print(start_min*60+start_sec)
        
        time = 300
        time -= (now_min*60+now_sec - start_min*60+start_sec)
    }
    
    func timeLimitStop(){
        startTimer = false
        timer.invalidate()
        time = 0
        timeDown.text = "--"
    }
    
    @objc func timeLimit(){
        if time > 0{
            time -= 1
            timeDown.text = "\(time/60):\(time%60)"
        }else{
            timeLimitStop()
        }
    }
    
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
    
    
    func get_reserve_info(_ url:String, student_no:String){
        var done = false
        let url:NSURL = NSURL(string: url)!
        let session = URLSession.shared

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"

        let paramString = "student_no="+student_no
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
                self.reserve_info = (dataString as String).components(separatedBy: "_")
                done = true
            }
        }
        
        task.resume()
        repeat {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        } while !done
    }
    
}
