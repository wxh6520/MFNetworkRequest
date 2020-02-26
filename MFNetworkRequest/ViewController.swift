//
//  ViewController.swift
//  MFNetworkRequest
//
//  Created by 王雪慧 on 2020/2/25.
//  Copyright © 2020 王雪慧. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let request = MFNetworkRequest()
        let dicParameter = ["email": "wangxuehuiyangmi@sina.com",
                            "type": "JSON",
                            "action": "query"]
        request.sendDataPostRequest(url: "http://www.51work6.com/service/mynotes/WebService.php", parameter: dicParameter, successBlock: { [unowned self] (successStr) in
            let alert = UIAlertController(title: "成功报文", message: successStr, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }) { [unowned self] (failStr) in
            let alert = UIAlertController(title: "失败报文", message: failStr, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }


}

