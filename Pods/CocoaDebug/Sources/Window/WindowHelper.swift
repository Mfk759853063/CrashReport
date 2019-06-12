//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit

public class WindowHelper: NSObject {
    public static let shared = WindowHelper()
    
    var window: CocoaDebugWindow?
    var displayedList = false
    lazy var vc = CocoaDebugViewController()
    
    private override init() {
        let y = UIApplication.shared.statusBarFrame.size.height
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height - UIApplication.shared.statusBarFrame.size.height
        self.window = CocoaDebugWindow(frame: CGRect(x: 0, y: y, width: width, height: height))
        super.init()
    }

    public func enable() {
        if self.window?.rootViewController != self.vc {
            self.window?.rootViewController = self.vc
            self.window?.delegate = self
            self.window?.isHidden = false
            _WHDebugFPSMonitor.sharedInstance()?.startMonitoring()
            _WHDebugMemoryMonitor.sharedInstance()?.startMonitoring()
            _WHDebugCpuMonitor.sharedInstance()?.startMonitoring()
        }
    }

    public func disable() {
        if self.window?.rootViewController != nil {
            self.window?.rootViewController = nil
            self.window?.delegate = nil
            self.window?.isHidden = true
            _WHDebugFPSMonitor.sharedInstance()?.stopMonitoring()
            _WHDebugMemoryMonitor.sharedInstance()?.stopMonitoring()
            _WHDebugCpuMonitor.sharedInstance()?.stopMonitoring()
        }
    }
}
