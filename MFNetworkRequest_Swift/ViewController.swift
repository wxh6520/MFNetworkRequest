//
//  ViewController.swift
//  MFNetworkRequest_Swift
//
//  Created by 王雪慧 on 2017/1/5.
//  Copyright © 2017年 王雪慧. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var text: UITextView!
    
    @IBAction func send(_ sender: Any) {
        
        let login = MFNetworkRequest()
        login.sendDataGetRequest(url: "https://www.baidu.com", successBlock: { (successStr) in
            self.text.text = successStr
        }) { (failStr) in
            self.text.text = failStr
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

