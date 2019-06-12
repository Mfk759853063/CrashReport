//
//  View2ViewController.swift
//  TestLog
//
//  Created by vbn on 2019/6/11.
//  Copyright © 2019 pori. All rights reserved.
//

import UIKit
class View2ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        KNCrashReport.shared.log( "View2ViewController")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(2), execute: {
            KNCrashReport.shared.log( "准备crash吧")
            let a = AAA()
        })
    }
    
    deinit {
        KNCrashReport.shared.log("deinit")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
