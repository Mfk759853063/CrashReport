//
//  KNLogger.swift
//  TestLog
//
//  Created by vbn on 2019/6/10.
//  Copyright © 2019 pori. All rights reserved.
//

import UIKit


private let KNCrashReportFileName = "crashReport.log"

private let KNCrashReportTrakingFileName = "traking.log"

private let KNCrashReportUploadURL = "http://log.kwepvbn.com/upload"

private class KNCrashReportMessage: NSObject {
    var message: String?
    var function: String?
    var line: String?
    
    
    func print() -> String{
        return "\nfunctionName: \(function ?? "")\tline: \(line ?? "")\tmessage: \(message ?? "")\n"
    }
    
    func data() -> Data{
        return self.print().data(using: .utf8) ?? Data()
    }
}

@objc class KNCrashReport: NSObject {
    
    private let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    private var fileHandle: FileHandle?
    
    private var writeThread: Thread?
    
    private var uploadCrashLogCallback: ((URL) -> Bool)?
    
    @objc static let shared = KNCrashReport()
    
    private override init() {}
    
    @objc func log(_ message: String = "", function: String? = #function, line: Int = #line) {
        DispatchQueue.global().async {
            let msg = KNCrashReportMessage()
            msg.function = function
            msg.line = "\(line)"
            msg.message = message
            if let thread = self.writeThread {
                self.perform(#selector(self.writeData(_:)), on: thread, with: msg, waitUntilDone: false)
            }
        }
    }
    
    func startTrack(uploadCrashCallback: ((URL) -> Bool)?) {
    
        self.writeThread = Thread.init(target: self, selector: #selector(self.threadRun), object: nil)
        self.writeThread?.start()

        // 异常捕获
        NSSetUncaughtExceptionHandler { exception in
            let documentPath =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            var logPath = URL(fileURLWithPath: documentPath)
            logPath.appendPathComponent(KNCrashReportTrakingFileName)
            var crashReportPath = URL(fileURLWithPath: documentPath)
            crashReportPath.appendPathComponent(KNCrashReportFileName)

            var data = try? Data(contentsOf: logPath)
            data?.append("\n**************crash report*******************\n".data(using: .utf8) ?? Data())
            data?.append("\n**************crash reason*******************\n".data(using: .utf8) ?? Data())
            data?.append((exception.reason ?? "").data(using: .utf8) ?? Data())
            data?.append("\n**************crash callStackReturnAddresses*******************\n".data(using: .utf8) ?? Data())
            let numbersStr = exception.callStackReturnAddresses.map{"\($0)"}.joined(separator: "\n")
            data?.append( numbersStr.data(using: .utf8) ?? Data())
            data?.append("\n**************crash callStackSymbols*******************\n".data(using: .utf8) ?? Data())
            data?.append(exception.callStackSymbols.joined(separator: "\n").data(using: .utf8) ?? Data())
            data?.append("\n**************crash report end*******************\n".data(using: .utf8) ?? Data())
            try? data?.write(to: crashReportPath)
        }
        
        signal(SIGABRT, signalExceptionHandler);
        signal(SIGILL, signalExceptionHandler);
        signal(SIGSEGV, signalExceptionHandler);
        signal(SIGFPE, signalExceptionHandler);
        signal(SIGBUS, signalExceptionHandler);
        signal(SIGTRAP, signalExceptionHandler)
        signal(SIGPIPE, signalExceptionHandler);

    }
    
    @objc private func threadRun() {
        autoreleasepool{

            self.uploadCrashLog()
            self.createTrackFile()

            let loop = RunLoop.current
            loop.add(Port.init(), forMode: .default)
            loop.run()
        }

    }
    
    @objc private func writeData(_ msg: KNCrashReportMessage) {
        
        #if DEBUG
        print(msg.print())
        #endif
        
        self.fileHandle?.write(msg.data())
    }
    
    
    // MARK: - 创建记录文件
    
    @objc private  func createTrackFile() {
        
        var loggerFileUrl = URL(fileURLWithPath: documentPath)
        loggerFileUrl.appendPathComponent(KNCrashReportTrakingFileName)

        do {
            try FileManager.default.removeItem(at: loggerFileUrl)
        } catch  {}

        do {
            try "".write(to: loggerFileUrl, atomically: true, encoding: .utf8)
            fileHandle = try FileHandle.init(forWritingTo: loggerFileUrl)
            fileHandle?.write("**************start track*******************\n".data(using: .utf8) ?? Data())
        } catch let error {
            print("创建文件失败\(error)")
        }
        
    }

    
    private func uploadCrashLog() {
        var crashFileUrl = URL(fileURLWithPath: documentPath)
        crashFileUrl.appendPathComponent(KNCrashReportFileName)
        if FileManager.default.fileExists(atPath: crashFileUrl.path) {
            if let block = self.uploadCrashLogCallback {
                if block(crashFileUrl) {
                    try? FileManager.default.removeItem(at: crashFileUrl)
                }
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
                let dateStr = dateFormatter.string(from: Date())
                self.uploadFiles(crashFileUrl, "\(dateStr)-\(KNCrashReportFileName)")
            }
            
        }
    }
    
    func uploadFiles(_ filePath: URL, _ fileName: String){
        
        if let url = URL(string: KNCrashReportUploadURL){
            var request = URLRequest(url: url)
            let boundary:String = "Boundary-\(UUID().uuidString)"
            
            request.httpMethod = "POST"
            request.timeoutInterval = 10
            request.allHTTPHeaderFields = ["Content-Type": "multipart/form-data; boundary=----\(boundary)"]
            
            var data2: Data = Data()
            var data: Data = Data()
            data2 = try! Data.init(contentsOf: filePath)
            
            let key = "kwepvbn"
            let value = "admin123"
            
            data.KNCrashAppend("------\(boundary)\r\n")
            data.KNCrashAppend("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            data.KNCrashAppend("\(value)\r\n")
            
            
            data.KNCrashAppend("------\(boundary)\r\n")
            //Here you have to change the Content-Type
            data.KNCrashAppend("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
            data.KNCrashAppend("Content-Type: application/json\r\n\r\n")
            data.append(data2)
            data.KNCrashAppend("\r\n")
            data.KNCrashAppend("------\(boundary)--")
            
            request.httpBody = data
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).sync {
                let session = URLSession.shared
                _ = session.dataTask(with: request, completionHandler: { (dataS, aResponse, error) in
                    if let _ = error{
                        print(error?.localizedDescription ?? "")
                    }else{
                        try? FileManager.default.removeItem(at: filePath)
                    }
                }).resume()
            }
        }
    }
}

fileprivate func signalExceptionHandler(signal:Int32) -> Void {
    let documentPath =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    var logPath = URL(fileURLWithPath: documentPath)
    logPath.appendPathComponent(KNCrashReportTrakingFileName)
    var crashReportPath = URL(fileURLWithPath: documentPath)
    crashReportPath.appendPathComponent(KNCrashReportFileName)
    
    var data = try? Data(contentsOf: logPath)
    data?.append("\n**************crash report*******************\n".data(using: .utf8) ?? Data())
    data?.append("\n**************crash signal*******************\n".data(using: .utf8) ?? Data())
    let signalStr = "\(signal)"
    data?.append( signalStr.data(using: .utf8) ?? Data())
    data?.append("\n**************crash callStackReturnAddresses*******************\n".data(using: .utf8) ?? Data())
    let numbersStr = Thread.callStackReturnAddresses.map{"\($0)"}.joined(separator: "\n")
    data?.append( numbersStr.data(using: .utf8) ?? Data())
    data?.append("\n**************crash callStackSymbols*******************\n".data(using: .utf8) ?? Data())
    data?.append(Thread.callStackSymbols.joined(separator: "\n").data(using: .utf8) ?? Data())
    data?.append("\n**************crash report end*******************\n".data(using: .utf8) ?? Data())
    try? data?.write(to: crashReportPath)
}

extension Data{
    mutating func KNCrashAppend(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}






