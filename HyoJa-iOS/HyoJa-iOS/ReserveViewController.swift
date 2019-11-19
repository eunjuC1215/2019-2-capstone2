//
//  ReserveViewController.swift
//  HyoJa-iOS
//
//  Created by Jeongho on 2019/11/07.
//  Copyright © 2019 eomjeongho. All rights reserved.
//

import UIKit

class ReserveViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        seat_info_request("http://13.124.28.135/getSeatsData.php")
    }

    func seat_info_request(_ url:String)
    {
        let url:NSURL = NSURL(string: url)!
        let session = URLSession.shared

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"

        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in

            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                 print(error?.localizedDescription ?? "No data")
                return
            }

            if let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            {
                print(dataString)
            }
        }
        
        task.resume()
    }
}
