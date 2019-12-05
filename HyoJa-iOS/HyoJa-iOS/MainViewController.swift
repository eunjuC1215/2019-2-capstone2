//
//  MainViewController.swift
//  HyoJa-iOS
//
//  Created by Jeongho on 2019/11/04.
//  Copyright © 2019 eomjeongho. All rights reserved.
//

import UIKit
import UserNotifications
import MobileCoreServices

class MainViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var taskID: UIBackgroundTaskIdentifier?
    var number: Int = 0
    
    // MARK: @IBOUTLET
    @IBOutlet weak var SeatNo: UILabel!
    @IBOutlet var timeDown: UILabel!
    @IBOutlet var seatReserve: UIButton!
    @IBOutlet var QRscaner: UIButton!
    @IBOutlet var reserveCancle: UIButton!
    @IBOutlet var reserveExtension: UIButton!
    @IBOutlet var Logout: UIButton!
    
    // MARK: Var
    var timelimit : [String] = []
    var time = 0
    var timer = Timer()
    var startTimer = false //타이머 중복 방지용
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seatReserve.layer.cornerRadius = 10
        QRscaner.layer.cornerRadius = 10
        reserveCancle.layer.cornerRadius = 10
        reserveExtension.layer.cornerRadius = 10
        Logout.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        taskID = UIApplication.shared.beginBackgroundTask(expirationHandler: ({
            UIApplication.shared.endBackgroundTask(self.taskID!)
            self.taskID = .invalid
            
        }))
        
        self.SeatNo.text = String(UserDefaults.standard.string(forKey: "seat_no") ?? "--" )
        let isReserved = SeatNo.text
        if(isReserved != "--"){
            print("돌아옴")
            makeTime()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainViewController.timeLimit), userInfo: nil, repeats: true)
        }
    }
    
    func makeTime(){
        let UserId = UserDefaults.standard.string(forKey: "id")
        timelimit = self.isReserve("http://13.124.28.135/isReserve.php", student_no: UserId!)
        print(timelimit.count)
        if(timelimit.count == 4){
            let option = timelimit[3]
            let reservetime = timelimit[2].components(separatedBy: " ")[1]
            let res_hour:Int = Int(reservetime.components(separatedBy: ":")[0]) ?? 0
            let res_min:Int = Int(reservetime.components(separatedBy: ":")[1]) ?? 0
            let res_sec:Int = Int(reservetime.components(separatedBy: ":")[2]) ?? 0
            
            
            let nowtime = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            let dateString = dateFormatter.string(from: nowtime)
            let now_hour:Int = Int(dateString.components(separatedBy: ":")[0]) ?? 0
            let now_min:Int = Int(dateString.components(separatedBy: ":")[1]) ?? 0
            let now_sec:Int = Int(dateString.components(separatedBy: ":")[2]) ?? 0
            
            let hour = res_hour - now_hour
            let min = res_min - now_min
            let sec = res_sec - now_sec
            
            if(option == "1"){
                self.time = min * 60 + sec
                print(self.time)
            }
            else if(option == "2"){
                self.time = hour*60*60 + min*60 + sec
            }
        }
        else{
            self.time = 0
        }
        print("time: ")
        print(self.time)
    }
    
    func timeLimitStart(){
        makeTime()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainViewController.timeLimit), userInfo: nil, repeats: true)
    }
    
    @objc func timeLimit(){
        if time > 0{
            time -= 1
            var min = String(time/60)
            var sec = String(time%60)
            if(time/60 < 10) {min="0"+min}
            if(time%60 < 10) {sec="0"+sec}
            timeDown.text = "\(min):\(sec)"

            if(time == 601){
                schedulNotification(inSeconds: 1, string: "예약 시간이 10분 남았습니다", completion: {success in
                    if success{
                        print("성공")
                    }else{
                        print("error")
                    }
                })
            }
        }
        else{
            schedulNotification(inSeconds: 0.1, string: "좌석이 반납되었습니다", completion: {success in
                if success{
                    print("성공")
                }else{
                    print("error")
                }
            })
            timeLimitStop()
        }
    }
    
    func timeLimitStop(){
        //startTimer = false
        timer.invalidate()
        SeatNo.text = "--"
        timeDown.text = "--:--"
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
        if(isReserved == "--"){
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
        else{
            if (time > 10*60) {  //10분 이상 남았을 때
                let alert = UIAlertController(title: "좌석 연장 실패", message: "10분 전부터 연장 가능합니다", preferredStyle: UIAlertController.Style.alert)
                let cancle = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel)
                alert.addAction(cancle)
                self.present(alert, animated: false)
            }
            else{
                var student_id = ""
                if let id = UserDefaults.standard.string(forKey: "id"){
                    student_id = id
                }
                self.requestExtend("http://13.124.28.135/extend.php", student_no: student_id )
                let refresh = self.storyboard?.instantiateViewController(identifier: "Main")
                refresh?.modalPresentationStyle = .fullScreen
                self.present(refresh!, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func Logout(_ sender: UIButton){
        if(timer.isValid){
            timer.invalidate()
        }
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
            self.timeLimitStop()
            self.viewWillAppear(true)
        }
        let cancle = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel)
        alert.addAction(cancle)
        alert.addAction(enter)
        self.present(alert, animated: false)
    }
    
    // MARK: Notification
    func schedulNotification(inSeconds: TimeInterval, string:String, completion: @escaping(_ Success: Bool)->()){
        let notification = UNMutableNotificationContent()
        notification.title = "HyoJa"
        notification.body = string
        notification.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:inSeconds, repeats: false)
        let request = UNNotificationRequest(identifier: "10min", content: notification, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
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
    
    func isReserve(_ url:String, student_no:String) -> [String]{
        var done: Bool! = false
        var timelimit: [String] = []
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
                if(dataString != "0"){
                    timelimit = (dataString as String).components(separatedBy: "_")
                }
                else{
                    timelimit.append(dataString as String)
                }
                done = true
            }
        }
        
        task.resume()
        repeat {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        } while !done
        
        return timelimit
    }
    
    func requestExtend(_ url:String, student_no:String){
        var done: Bool! = false
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
