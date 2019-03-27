//
//  MFNetworkRequest.swift
//  MFNetworkRequest_Swift
//
//  Created by 王雪慧 on 2017/1/5.
//  Copyright © 2017年 王雪慧. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

public enum MFNetworkRequestUsage {
    case Data //数据
    case Download //下载
    case Upload //上传
}

public enum MFHttpMethod:String {
    case GET //GET请求
    case POST //POST请求
}

@objc public class MFNetworkRequest: NSObject {
    
    fileprivate static let MBGray = UIColor(red: 180/255.0, green: 180/255.0, blue: 180/255.0, alpha: 0.8) //MBProgressHUD灰
    
    fileprivate var networkRequestUsage = MFNetworkRequestUsage.Data
    fileprivate var myConn:NSURLConnection?
    fileprivate var mySession:URLSession?
    fileprivate var downloadTask:URLSessionDownloadTask?
    fileprivate var downloadResumeData:Data?
    fileprivate var responseData = NSMutableData()
    fileprivate var writeHandle:FileHandle?
    fileprivate var downloadOrUploadFilePath:NSString = ""
    fileprivate var totalLength:Int64 = 0
    fileprivate var currentLength:Int64 = 0
    fileprivate var isLoading = true
    fileprivate var hud:MBProgressHUD?
    fileprivate var isManualSuspend = false
    fileprivate var downloadRequest:NSMutableURLRequest?
    fileprivate var downloadOrUploadFileProgressBlock:((Float)->Void)?
    fileprivate var requestSuccessBlock:((String)->Void)?
    fileprivate var requestFailedBlock:((String)->Void)?
    
}

extension MFNetworkRequest: NSURLConnectionDataDelegate,URLSessionDataDelegate,URLSessionDownloadDelegate {
    
    //MARK:发送报文GET请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - timeoutInterval: 超时时间/S
    ///   - asynchronous: 同步/异步
    ///   - loading: 显示/不显示请求加载框
    ///   - successBlock: 请求成功回调
    ///   - failedBlock: 请求失败回调
    /// - Returns: 空
    public func sendDataGetRequest(url:String,
                                   timeoutInterval:TimeInterval = 60,
                                   asynchronous:Bool = true,
                                   loading:Bool = true,
                                   successBlock:@escaping (String)->Void = { _ in },
                                   failedBlock:@escaping (String)->Void = { _ in }) {
        
        sendRequest(url: url,
                    parameter: nil,
                    timeoutInterval: timeoutInterval,
                    httpMethod: .GET,
                    asynchronous: asynchronous,
                    loading: loading,
                    usage: .Data,
                    downloadOrUploadPath: "",
                    downloadOrUploadProgressBlock: { _ in },
                    successBlock: successBlock,
                    failedBlock: failedBlock)
        
    }
    
    //MARK:发送报文POST请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameter: 请求参数
    ///   - timeoutInterval: 超时时间/S
    ///   - asynchronous: 同步/异步
    ///   - loading: 显示/不显示请求加载框
    ///   - successBlock: 请求成功回调
    ///   - failedBlock: 请求失败回调
    /// - Returns: 空
    public func sendDataPostRequest(url:String,
                                    parameter:Dictionary<String,String>,
                                    timeoutInterval:TimeInterval = 60,
                                    asynchronous:Bool = true,
                                    loading:Bool = true,
                                    successBlock:@escaping (String)->Void = { _ in },
                                    failedBlock:@escaping (String)->Void = { _ in }) {
        
        sendRequest(url: url,
                    parameter: parameter,
                    timeoutInterval: timeoutInterval,
                    httpMethod: .POST,
                    asynchronous: asynchronous,
                    loading: loading,
                    usage: .Data,
                    downloadOrUploadPath: "",
                    downloadOrUploadProgressBlock: { _ in },
                    successBlock: successBlock,
                    failedBlock: failedBlock)
        
    }
    
    //MARK:发送下载GET请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - timeoutInterval: 超时时间/S
    ///   - asynchronous: 同步/异步
    ///   - loading: 显示/不显示请求加载框
    ///   - downloadOrUploadPath: 下载/上传文件路径
    ///   - downloadOrUploadProgressBlock: 下载/上传进度回调
    ///   - successBlock: 请求成功回调
    ///   - failedBlock: 请求失败回调
    /// - Returns: 空
    public func sendDownloadGetRequest(url:String,
                                       timeoutInterval:TimeInterval = 60,
                                       asynchronous:Bool = true,
                                       loading:Bool = true,
                                       downloadOrUploadPath:String,
                                       downloadOrUploadProgressBlock:@escaping (Float)->Void = { _ in },
                                       successBlock:@escaping (String)->Void = { _ in },
                                       failedBlock:@escaping (String)->Void = { _ in }) {
        
        sendRequest(url: url,
                    parameter: nil,
                    timeoutInterval: timeoutInterval,
                    httpMethod: .GET,
                    asynchronous: asynchronous,
                    loading: loading,
                    usage: .Download,
                    downloadOrUploadPath: downloadOrUploadPath,
                    downloadOrUploadProgressBlock: downloadOrUploadProgressBlock,
                    successBlock: successBlock,
                    failedBlock: failedBlock)
        
    }
    
    //MARK:发送下载POST请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameter: 请求参数
    ///   - timeoutInterval: 超时时间/S
    ///   - asynchronous: 同步/异步
    ///   - loading: 显示/不显示请求加载框
    ///   - downloadOrUploadPath: 下载/上传文件路径
    ///   - downloadOrUploadProgressBlock: 下载/上传进度回调
    ///   - successBlock: 请求成功回调
    ///   - failedBlock: 请求失败回调
    /// - Returns: 空
    public func sendDownloadPostRequest(url:String,
                                        parameter:Dictionary<String,String>,
                                        timeoutInterval:TimeInterval = 60,
                                        asynchronous:Bool = true,
                                        loading:Bool = true,
                                        downloadOrUploadPath:String,
                                        downloadOrUploadProgressBlock:@escaping (Float)->Void = { _ in },
                                        successBlock:@escaping (String)->Void = { _ in },
                                        failedBlock:@escaping (String)->Void = { _ in }) {
        
        sendRequest(url: url,
                    parameter: parameter,
                    timeoutInterval: timeoutInterval,
                    httpMethod: .POST,
                    asynchronous: asynchronous,
                    loading: loading,
                    usage: .Download,
                    downloadOrUploadPath: downloadOrUploadPath,
                    downloadOrUploadProgressBlock: downloadOrUploadProgressBlock,
                    successBlock: successBlock,
                    failedBlock: failedBlock)
        
    }
    
    //MARK:发送上传POST请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameter: 请求参数
    ///   - timeoutInterval: 超时时间/S
    ///   - asynchronous: 同步/异步
    ///   - loading: 显示/不显示请求加载框
    ///   - downloadOrUploadPath: 下载/上传文件路径
    ///   - downloadOrUploadProgressBlock: 下载/上传进度回调
    ///   - successBlock: 请求成功回调
    ///   - failedBlock: 请求失败回调
    /// - Returns: 空
    public func sendUploadPostRequest(url:String,
                                      parameter:Dictionary<String,String>? = nil,
                                      timeoutInterval:TimeInterval = 60,
                                      asynchronous:Bool = true,
                                      loading:Bool = true,
                                      downloadOrUploadPath:String,
                                      downloadOrUploadProgressBlock:@escaping (Float)->Void = { _ in },
                                      successBlock:@escaping (String)->Void = { _ in },
                                      failedBlock:@escaping (String)->Void = { _ in }) {
        
        sendRequest(url: url,
                    parameter: parameter,
                    timeoutInterval: timeoutInterval,
                    httpMethod: .POST,
                    asynchronous: asynchronous,
                    loading: loading,
                    usage: .Upload,
                    downloadOrUploadPath: downloadOrUploadPath,
                    downloadOrUploadProgressBlock: downloadOrUploadProgressBlock,
                    successBlock: successBlock,
                    failedBlock: failedBlock)
        
    }
    
    //MARK:发送请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameter: 请求参数
    ///   - timeoutInterval: 超时时间/S
    ///   - httpMethod: 请求方式(GET/POST)
    ///   - asynchronous: 同步/异步
    ///   - loading: 显示/不显示请求加载框
    ///   - usage: 用途：数据/下载/上传
    ///   - downloadOrUploadPath: 下载/上传文件路径
    ///   - downloadOrUploadProgressBlock: 下载/上传进度回调
    ///   - successBlock: 请求成功回调
    ///   - failedBlock: 请求失败回调
    /// - Returns: 空
    private func sendRequest(url:String,
                             parameter:Dictionary<String,String>?,
                             timeoutInterval:TimeInterval,
                             httpMethod:MFHttpMethod,
                             asynchronous:Bool,
                             loading:Bool,
                             usage:MFNetworkRequestUsage,
                             downloadOrUploadPath:String,
                             downloadOrUploadProgressBlock:@escaping (Float)->Void,
                             successBlock:@escaping (String)->Void,
                             failedBlock:@escaping (String)->Void) {
        
        isLoading = loading
        
        if isLoading{
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }else{
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        switch usage {
        case .Data:
            
            networkRequestUsage = .Data
            
            let request = createRequest(url: url, parameter: parameter, timeoutInterval: timeoutInterval, httpMethod: httpMethod)
            
            if isLoading {
                
                let keyWindow = UIApplication.shared.keyWindow
                if keyWindow != nil {
                    hud = MBProgressHUD.showAdded(to: keyWindow!, animated: true)
                    hud?.bezelView.color = MFNetworkRequest.MBGray
                    hud?.label.text = "Loading..."
                }
                
            }
            
            if asynchronous {
                
                // 异步
                if #available(iOS 8.0, *) {
                    
                    requestSuccessBlock = successBlock
                    requestFailedBlock = failedBlock
                    
                    let config = URLSessionConfiguration.default
                    config.timeoutIntervalForRequest = timeoutInterval
                    config.allowsCellularAccess = true
                    config.isDiscretionary = true
                    mySession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
                    let dataTask = mySession?.dataTask(with: request as URLRequest)
                    dataTask?.resume()
                    
                } else {
                    
                    NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: .main, completionHandler: { (response, data, connectionError) in
                        
                        if let err = connectionError{
                            failedBlock(err.localizedDescription)
                        }else{
                            let returnStr = NSString(data: data ?? Data(), encoding: String.Encoding.utf8.rawValue) ?? ""
                            print("returnData = \(returnStr)")
                            successBlock(returnStr as String)
                        }
                        
                    })
                    
                    hideLoading()
                    
                }
                
            } else {
                
                // 同步
                if #available(iOS 8.0, *) {
                    
                    requestSuccessBlock = successBlock
                    requestFailedBlock = failedBlock
                    
                    let config = URLSessionConfiguration.default
                    config.timeoutIntervalForRequest = timeoutInterval
                    config.allowsCellularAccess = true
                    config.isDiscretionary = true
                    mySession = URLSession(configuration: config, delegate: self, delegateQueue: .main)
                    let dataTask = mySession?.dataTask(with: request as URLRequest)
                    dataTask?.resume()
                    
                } else {
                    
                    do {
                        let returnData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: nil)
                        
                        let returnStr = NSString(data: returnData, encoding: String.Encoding.utf8.rawValue) ?? ""
                        print("returnData = \(returnStr)")
                        successBlock(returnStr as String)
                    } catch let err {
                        failedBlock(err.localizedDescription)
                    }
                    
                    hideLoading()
                    
                }
                
            }
            
        case .Download:
            
            networkRequestUsage = .Download
            
            downloadOrUploadFilePath = NSString(string: downloadOrUploadPath)
            downloadOrUploadFileProgressBlock = downloadOrUploadProgressBlock
            requestSuccessBlock = successBlock
            requestFailedBlock = failedBlock
            
            downloadRequest = createRequest(url: url, parameter: parameter, timeoutInterval: timeoutInterval, httpMethod: httpMethod)
            
            if isLoading {
                
                let keyWindow = UIApplication.shared.keyWindow
                if keyWindow != nil {
                    hud = MBProgressHUD.showAdded(to: keyWindow!, animated: true)
                    hud?.mode = .determinateHorizontalBar
                    hud?.label.text = "下载中..."
                }
                
            }
            
            do {
                try FileManager.default.removeItem(atPath: downloadOrUploadFilePath as String)
            } catch {
                
            }
            
            if #available(iOS 8.0, *) {
                
                let config = URLSessionConfiguration.background(withIdentifier: "MFNetworkRequest")
                config.timeoutIntervalForRequest = timeoutInterval
                config.allowsCellularAccess = true
                config.isDiscretionary = true
                mySession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
                downloadTask = mySession?.downloadTask(with: downloadRequest! as URLRequest)
                downloadTask?.resume()
                
            } else {
                
                myConn = NSURLConnection(request: downloadRequest! as URLRequest, delegate: self)
                if myConn == nil {
                    failedBlock("创建下载NSURLConnection失败")
                }
                
            }
            
        case .Upload:
            
            networkRequestUsage = .Upload
            
            downloadOrUploadFilePath = NSString(string: downloadOrUploadPath)
            downloadOrUploadFileProgressBlock = downloadOrUploadProgressBlock
            requestSuccessBlock = successBlock
            requestFailedBlock = failedBlock
            
            let request = createUploadRequest(url: url, parameter: parameter, timeoutInterval: timeoutInterval)
            
            
            if isLoading {
                
                let keyWindow = UIApplication.shared.keyWindow
                if keyWindow != nil {
                    hud = MBProgressHUD.showAdded(to: keyWindow!, animated: true)
                    hud?.mode = .determinateHorizontalBar
                    hud?.label.text = "上传中..."
                }
                
            }
            
            if #available(iOS 8.0, *) {
                
                let config = URLSessionConfiguration.background(withIdentifier: "MFNetworkRequest")
                config.timeoutIntervalForRequest = timeoutInterval
                config.allowsCellularAccess = true
                config.isDiscretionary = true
                mySession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
                let uploadTask = mySession?.dataTask(with: request as URLRequest)
                uploadTask?.resume()
                
            } else {
                
                myConn = NSURLConnection(request: request as URLRequest, delegate: self)
                if myConn == nil {
                    failedBlock("创建上传NSURLConnection失败")
                }
                
            }
            
        }
        
    }
    
    private func createRequest(url:String,
                               parameter:Dictionary<String,String>?,
                               timeoutInterval:TimeInterval,
                               httpMethod:MFHttpMethod) -> NSMutableURLRequest {
        
        let baseUrl = String(url as NSString)
        var request:NSMutableURLRequest
        
        switch httpMethod {
        case .GET:
            
            // 默认为GET请求
            var entireUrl = NSMutableString()
            if let paramDic = parameter{
                
                entireUrl = NSMutableString(format: "%@?", baseUrl)
                for (index,pair) in paramDic.enumerated() {
                    if index == paramDic.count-1{
                        entireUrl.appendFormat("%@=%@", pair.key,pair.value)
                    }else{
                        entireUrl.appendFormat("%@=%@&", pair.key,pair.value)
                    }
                }
                
            }else{
                entireUrl = NSMutableString(string: baseUrl)
            }
            
            var urlStr = String()
            if #available(iOS 8.0, *) {
                
                urlStr = entireUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                
            } else {
                
                urlStr = entireUrl.addingPercentEscapes(using: String.Encoding.utf8.rawValue) ?? ""
                
            }
            
            request = NSMutableURLRequest(url: URL(string: urlStr)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeoutInterval)
            
        case .POST:
            
            // POST请求
            var urlStr = NSString()
            if #available(iOS 8.0, *) {
                
                urlStr = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) as NSString? ?? ""
                
            } else {
                
                urlStr = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) as NSString? ?? ""
                //                urlStr = baseUrl.addingPercentEscapes(using: .utf8) as NSString? ?? ""
                
            }
            
            request = NSMutableURLRequest(url: URL(string: urlStr as String)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeoutInterval)
            request.httpMethod = "POST"
            let paramBody = NSMutableString()
            if let paramDic = parameter{
                
                for (index,pair) in paramDic.enumerated() {
                    if index == paramDic.count-1{
                        paramBody.appendFormat("%@=%@", pair.key,pair.value)
                    }else{
                        paramBody.appendFormat("%@=%@&", pair.key,pair.value)
                    }
                }
                request.httpBody = paramBody.data(using: String.Encoding.utf8.rawValue)
                
            }
            
        }
        
        return request
        
    }
    
    private func createUploadRequest(url:String,
                                     parameter:Dictionary<String,String>?,
                                     timeoutInterval:TimeInterval) -> NSMutableURLRequest {
        
        let baseUrl = NSString(string: url)
        var request:NSMutableURLRequest
        // POST请求
        var urlStr = NSString()
        if #available(iOS 8.0, *) {
            
            urlStr = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) as NSString? ?? ""
            
        } else {
            
            urlStr = baseUrl.addingPercentEscapes(using: String.Encoding.utf8.rawValue) as NSString? ?? ""
            
        }
        
        request = NSMutableURLRequest(url: URL(string: urlStr as String)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeoutInterval)
        
        let bodyData = NSMutableData()
        let boundary = "MFNetworkRequest"
        let beginBoundary = NSString(format: "--%@", boundary)
        let endBoundary = NSString(format: "%@--", beginBoundary)
        let nameStr = "file" //要上传文件的key，可约定为其他
        let filenameStr = "file.png" //要上传文件的文件名，可约定为其他
        
        // 添加上传的参数
        if let paramDic = parameter {
            
            for (_,pair) in paramDic.enumerated() {
                
                let paramStr = NSMutableString()
                paramStr.appendFormat("%@\r\n", beginBoundary)
                paramStr.appendFormat("Content-Disposition: form-data; name=\"%@\"\r\n\r\n", pair.key)
                paramStr.appendFormat("%@\r\n", pair.value)
                bodyData.append(paramStr.data(using: String.Encoding.utf8.rawValue) ?? Data())
                
            }
            
        }
        
        // 添加上传的文件
        let fileStr = NSMutableString()
        fileStr.appendFormat("%@\r\n", beginBoundary)
        fileStr.appendFormat("Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", nameStr,filenameStr)
        fileStr.appendFormat("Content-Type: image/png\r\n\r\n")
        bodyData.append(fileStr.data(using: String.Encoding.utf8.rawValue) ?? Data())
        let fileData = NSData(contentsOfFile: downloadOrUploadFilePath as String) ?? NSData()
        bodyData.append(fileData as Data)
        bodyData.append("\r\n".data(using: .utf8) ?? Data())
        
        let endStr = NSString(format: "\r\n%@", endBoundary)
        bodyData.append(endStr.data(using: String.Encoding.utf8.rawValue) ?? Data())
        
        let content = NSString(format: "multipart/form-data; boundary=%@", boundary)
        request.setValue(content as String, forHTTPHeaderField: "Content-Type")
        request.setValue("\(bodyData.length)", forHTTPHeaderField: "Content-Length")
        request.httpBody = bodyData as Data
        request.httpMethod = "POST"
        
        return request
        
    }
    
    //MARK:--NSURLConnectionDataDelegate
    
    public func connection(_ connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
        
        switch networkRequestUsage {
        case .Upload:
            
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            DispatchQueue.main.async {
                self.hud?.progress = progress
            }
            downloadOrUploadFileProgressBlock?(progress)
            
        default:
            break
        }
        
    }
    
    public func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        
        switch networkRequestUsage {
        case .Download:
            
            // 下载方法1
            if !isManualSuspend {
                
                totalLength = response.expectedContentLength
                FileManager.default.createFile(atPath: downloadOrUploadFilePath as String, contents: nil, attributes: nil)
                writeHandle = FileHandle(forWritingAtPath: downloadOrUploadFilePath as String)
                writeHandle?.truncateFile(atOffset: UInt64(totalLength))
                
            }
            
            // 下载方法2
            //            if !isManualSuspend {
            //
            //                totalLength = response.expectedContentLength
            //            }
            
        default:
            break
        }
        
    }
    
    public func connection(_ connection: NSURLConnection, didReceive data: Data) {
        
        switch networkRequestUsage {
        case .Download:
            
            // 下载方法1
            writeHandle?.seek(toFileOffset: UInt64(currentLength))
            writeHandle?.write(data)
            currentLength += Int64((data as NSData).length)
            
            let progress = Float(currentLength) / Float(totalLength)
            DispatchQueue.main.async {
                self.hud?.progress = progress
            }
            downloadOrUploadFileProgressBlock?(progress)
            
            // 下载方法2
            //            responseData.append(data)
            //
            //            currentLength = Int64(responseData.length)
            //            let progress = Float(currentLength) / Float(totalLength)
            //            DispatchQueue.main.async {
            //                self.hud.progress = progress
            //            }
            //            downloadOrUploadFileProgressBlock(progress)
            
        case .Upload:
            
            responseData.append(data)
            
        default:
            break
        }
        
    }
    
    public func connectionDidFinishLoading(_ connection: NSURLConnection) {
        
        switch networkRequestUsage {
        case .Download:
            
            // 下载方法1
            writeHandle?.closeFile()
            
            print("下载成功，下载文件保存路径为:\(downloadOrUploadFilePath)")
            requestSuccessBlock?("Succeed:true\nDownloadPath:\(downloadOrUploadFilePath)")
            
            // 下载方法2
            //            if FileManager.default.createFile(atPath: downloadOrUploadFilePath as String, contents: nil, attributes: nil) {
            //
            //                print("下载成功，下载文件保存路径为:\(downloadOrUploadFilePath)")
            //                requestSuccessBlock("Succeed:true\nDownloadPath:\(downloadOrUploadFilePath)")
            //
            //            } else {
            //
            //                requestFailedBlock("创建下载文件失败")
            //            }
            
        case .Upload:
            
            let returnStr = NSString(data: responseData as Data, encoding: String.Encoding.utf8.rawValue) ?? ""
            print("returnData = \(returnStr)")
            requestSuccessBlock?(returnStr as String)
            
        default:
            break
        }
        
        hideLoading()
        
        myConn?.cancel()
        
    }
    
    public func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        
        switch networkRequestUsage {
        case .Download:
            
            // 下载方法1
            writeHandle?.closeFile()
            
            requestFailedBlock?(error.localizedDescription)
            
            // 下载方法2
            //            requestFailedBlock(error.localizedDescription)
            
        case .Upload:
            
            requestFailedBlock?(error.localizedDescription)
            
        default:
            break
        }
        
        hideLoading()
        
        myConn?.cancel()
        
    }
    
    //MARK:--URLSessionDataDelegate
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        
        switch networkRequestUsage {
        case .Download:
            
            completionHandler(.becomeDownload)
            
        default:
            
            completionHandler(.allow)
            
        }
        
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        
        switch networkRequestUsage {
        case .Download:
            
            break
            
        default:
            break
        }
        
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        responseData.append(data)
        
    }
    
    //MARK:--URLSessionDownloadDelegate
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        switch networkRequestUsage {
        case .Download:
            
            do {
                try FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: downloadOrUploadFilePath as String))
            } catch {
                
            }
            
        default:
            break
        }
        
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        switch networkRequestUsage {
        case .Download:
            
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            DispatchQueue.main.async {
                
                self.hud?.progress = progress
                
            }
            downloadOrUploadFileProgressBlock?(progress)
            
        default:
            break
        }
        
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
        switch networkRequestUsage {
        case .Download:
            
            break
            
        default:
            break
        }
        
    }
    
    //MARK:--NSURLSessionTaskDelegate
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        switch networkRequestUsage {
        case .Upload:
            
            let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
            DispatchQueue.main.async {
                
                self.hud?.progress = progress
                
            }
            downloadOrUploadFileProgressBlock?(progress)
            
        default:
            break
        }
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        DispatchQueue.main.async {
            
            if error == nil{
                
                let returnStr = NSString(data: self.responseData as Data, encoding: String.Encoding.utf8.rawValue) ?? ""
                print("returnData = \(returnStr)")
                self.requestSuccessBlock?(returnStr as String)
                
            }else{
                
                self.requestFailedBlock?((error?.localizedDescription) ?? "")
                
            }
            
            self.hideLoading()
            
            if !self.isManualSuspend{
                
                self.mySession?.invalidateAndCancel()
                
            }
            
        }
        
    }
    
    //MARK:--URLSessionDelegate
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        /*
         public func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Swift.Void) {
         saveCompletionHandler = completionHandler //完成回调保存起来
         }
         */
        // 在这里调用完成回调
        // saveCompletionHandler()
        
    }
    
    //MARK:下载暂停(可恢复)
    public func downloadSuspend() {
        
        isManualSuspend = true
        
        if #available(iOS 8.0, *) {
            
            downloadTask?.cancel(byProducingResumeData: { (resumeData) in
                
                self.downloadResumeData = resumeData
                
            })
            
        } else {
            
            myConn?.cancel()
            
        }
        
    }
    
    //MARK:下载继续
    public func downloadResume() {
        
        if #available(iOS 8.0, *) {
            
            isManualSuspend = false
            
            downloadTask = mySession?.downloadTask(withResumeData: downloadResumeData ?? Data())
            downloadTask?.resume()
            
        } else {
            
            let value = "bytes=\(currentLength)-"
            downloadRequest?.setValue(value, forHTTPHeaderField: "Range")
            
            myConn = NSURLConnection(request: downloadRequest! as URLRequest, delegate: self)
            if myConn == nil {
                
                requestFailedBlock?("创建下载NSURLConnection失败")
                
            }
            
        }
        
    }
    
    //MARK:下载取消
    public func downloadCancel() {
        
        if #available(iOS 8.0, *) {
            
            mySession?.invalidateAndCancel()
            
        } else {
            
            myConn?.cancel()
            requestFailedBlock?("下载取消")
            
        }
        
        hideLoading()
        
    }
    
    //MARK:隐藏请求加载框
    private func hideLoading() {
        
        DispatchQueue.main.async {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.hud?.hide(animated: true)
            
        }
        
    }
    
}
