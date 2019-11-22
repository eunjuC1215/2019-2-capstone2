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
    let seats = "++++++++ㅕㅑ/000_00_000/000_00_000/____00____/____00____/000_00_000/000_00_000/____00____/____00____/000____000/000____000/____00____/____00____/000_00_000/000_00_000/____00____/____00____/000_00_000/000_00_000/--------ㅓㅑ/"

    override func viewDidLoad() {
        super.viewDidLoad()

        seat_info_request("http://13.124.28.135/getSeatsData.php")
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
                   let label = UILabel(frame: CGRect(x: _x, y: _y, width: 30, height: 20))
                   label.textAlignment = .center
                   label.text = String(cnt)
                   if(seatInfo[idx] == "1"){
                       label.backgroundColor = UIColor.darkGray
                   }
                   else if seatInfo[idx] == "2"{
                       label.backgroundColor = UIColor.red
                   }
                   else{
                    label.backgroundColor = UIColor.green
                    }
                   self.view.addSubview(label)
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
