//
//  ReserveViewController.swift
//  HyoJa-iOS
//
//  Created by Jeongho on 2019/11/07.
//  Copyright © 2019 eomjeongho. All rights reserved.
//

import UIKit

class ReserveViewController: UIViewController {
    
    //let seats = "++++++++ㅕㅑ/__________/000_00_000/000_00_000/____00____/____00____/000_00_000/000_00_000/____00____/____00____/000____000/000____000/____00____/____00____/000_00_000/000_00_000/____00____/____00____/000_00_000/000_00_000/__________/--------ㅓㅏ/"
    let seats = "___+++++ㅕㅑ/000_00_000/000_00_000/____00____/____00____/000_00_000/000_00_000/____00____/____00____/000____000/000____000/____00____/____00____/000_00_000/000_00_000/____00____/____00____/000_00_000/000_00_000/--------ㅓㅑ/"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancleButton = UIButton(frame: CGRect(x:30, y:50, width: 100, height: 20))
        cancleButton.backgroundColor = .red
        cancleButton.layer.cornerRadius = 10
        cancleButton.setTitle("Cancle", for: .normal)
        cancleButton.addTarget(self, action: #selector(returnMain(_:)), for: .touchUpInside)
        view.addSubview(cancleButton)

        seat_info_request("http://13.124.28.135/getSeatsData.php")
    }
    
    @IBAction func returnMain(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func alreadyUsed(_ sender: UIButton){
        let alert = UIAlertController(title: "예약 불가", message: "사용중인 좌석입니다.", preferredStyle: UIAlertController.Style.alert)
        let cancle = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel)
        alert.addAction(cancle)
        self.present(alert, animated: false)
    }
    
    @IBAction func alreadyReserved(_ sender: UIButton){
        let alert = UIAlertController(title: "예약 불가", message: "예약된 좌석입니다.", preferredStyle: UIAlertController.Style.alert)
        let cancle = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel)
        alert.addAction(cancle)
        self.present(alert, animated: false)
    }
    
    @IBAction func reserve(_ sender: seatBtn){
        let alert = UIAlertController(title: "예약 하시겠습니까?", message: "", preferredStyle: UIAlertController.Style.alert)
        let enter = UIAlertAction(title:"예약", style: UIAlertAction.Style.default){
            (action) in
            var student_no = ""
            if let UserID = UserDefaults.standard.string(forKey: "id"){
                student_no = UserID
                print(student_no)
            }
            
            self.seat_reserve_request("http://13.124.28.135/reserve.php", student_no: student_no ,seat_no: sender.cnt ?? "0", option: "1")
            self.dismiss(animated: true, completion: nil)
        }
        let cancle = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel)
        alert.addAction(cancle)
        alert.addAction(enter)
        self.present(alert, animated: false)
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
        
        UserDefaults.standard.set(seat_no, forKey: "seat_no")
    }

    func seat_info_request(_ url:String)
    {
        var done: Bool! = false
        let url:NSURL = NSURL(string: url)!
        let session = URLSession.shared

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        
        var seatInfo: String = ""

        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in

            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                 print(error?.localizedDescription ?? "No data")
                return
            }

            if let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                done = true
                seatInfo = dataString as String
            }
        }
        
        task.resume()
        repeat {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        } while !done
        
        //let seatInfo = dataString as String
        var idx = seatInfo.startIndex
        var cnt = 1
        var _x = 50
        var _y = 50
        
        for seat in self.seats{
            if seat == "0"{ //seat
                   let btn = seatBtn(frame: CGRect(x: _x, y: _y, width: 30, height: 20))
                   //btn.textAlignment = .center
                btn.setTitle(String(cnt), for: .normal)
                   if(seatInfo[idx] == "1"){
                       btn.backgroundColor = UIColor.darkGray
                    btn.addTarget(self, action: #selector(alreadyReserved(_:)), for: .touchUpInside)

                   }
                   else if seatInfo[idx] == "2"{
                       btn.backgroundColor = UIColor.red
                    btn.addTarget(self, action: #selector(alreadyUsed(_:)), for: .touchUpInside)
                   }
                   else{
                    btn.backgroundColor = UIColor.green
                    let seat_no = String(cnt)
                    btn.cnt = seat_no
                    btn.addTarget(self, action: #selector(reserve(_:)), for:.touchUpInside)
                    }
                   self.view.addSubview(btn)
                   cnt += 1
                   _x += 31
                   _y += 0
                   idx = seatInfo.index(idx, offsetBy: 1)
                
            }
            else if seat == "/"{ //line end
                _x = 50
                _y += 41
            }
            else if seat == "+"{ //wall
                let label = UILabel(frame: CGRect(x: _x, y: _y, width: 30, height: 20))
                label.textAlignment = .center
                label.backgroundColor = UIColor.darkGray
                self.view.addSubview(label)
                _x += 31
                _y += 0
            }
            else if seat == "-"{ //glass
                let label = UILabel(frame: CGRect(x: _x, y: _y, width: 30, height: 20))
                label.textAlignment = .center
                label.backgroundColor = UIColor.systemTeal
                self.view.addSubview(label)
                _x += 31
                _y += 0
            }
            else if seat == "ㅕ"{ //glass
                let label = UILabel(frame: CGRect(x: _x, y: _y, width: 30, height: 20))
                label.textAlignment = .right
                label.text = String("뒷")
                self.view.addSubview(label)
                _x += 31
                _y += 0
            }
            else if seat == "ㅓ"{ //glass
                let label = UILabel(frame: CGRect(x: _x, y: _y, width: 30, height: 20))
                label.textAlignment = .right
                label.text = String("앞")
                self.view.addSubview(label)
                _x += 31
                _y += 0
            }
            else if seat == "ㅑ"{ //glass
                let label = UILabel(frame: CGRect(x: _x, y: _y, width: 30, height: 20))
                label.textAlignment = .left
                label.text = String("문")
                self.view.addSubview(label)
                _x += 31
                _y += 0
            }
            else{ //"_" blank
                _x += 31
                _y += 0
            }
        }
        
    }
}

class seatBtn: UIButton {
    var cnt: String?
}
