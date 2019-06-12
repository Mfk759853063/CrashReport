//
//  ViewController.swift
//  TestLog
//
//  Created by vbn on 2019/6/10.
//  Copyright © 2019 pori. All rights reserved.
//

import UIKit

struct TestStruct {
    var member1 = "1"
}

class ViewController: UIViewController {

    @IBOutlet weak var pressed: UIButton!
    
    var switchOn = false
    
    @IBAction func press(_ sender: Any) {
        KNCrashReport.shared.log("press")
    }
    
    @IBAction func crash(_ sender: Any) {
//        let a = [1,2,3]
//        a[4]

        let a = "123"
        let b = a as! Dictionary<String, String>
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(2)) {
            let struct1 = TestStruct()
            
            KNCrashReport.shared.log("hello im ViewController")
            KNCrashReport.shared.log("struct: \(struct1)")
            
            let v = View2ViewController()
            self.navigationController?.pushViewController(v, animated: true)
        }
        
        
        
        
        
//        let b = [1,2,3]
//        b[4]
//        var i = 0
//        while true {
//            i = i+1
//            print("\(i)")
//            sleep(1)
//        }
    }
    
    


}

