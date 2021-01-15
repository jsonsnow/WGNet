//
//  WGNetLayer.swift
//  WGNet
//
//  Created by chen liang on 2021/1/15.
//

import Foundation
import Moya
import Alamofire


class HTTPSManager: NSObject {
    
   func setAlamofireHttps() {
        
        SessionManager.default.delegate.sessionDidReceiveChallenge = { (session: URLSession, challenge: URLAuthenticationChallenge) in
            
            let method = challenge.protectionSpace.authenticationMethod
            
            if method == NSURLAuthenticationMethodServerTrust {
                
                //验证服务器，直接信任或者验证证书二选一，推荐验证证书，更安全
                return HTTPSManager.trustServerWithCer(challenge: challenge)
//                return HTTPSManager.trustServer(challenge: challenge)
                
            } else if method == NSURLAuthenticationMethodClientCertificate {
                
                //认证客户端证书
                return HTTPSManager.sendClientCer()
                
            } else {
                
                //其他情况，不通过验证
                return (.cancelAuthenticationChallenge, nil)
                
            }
            
        }
        
    }
    
    //不做任何验证，直接信任服务器
    static private func trustServer(challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        
        let disposition = URLSession.AuthChallengeDisposition.useCredential
        let credential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
        return (disposition, credential)
        
    }
    
    //验证服务器证书
    static private func trustServerWithCer(challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        
        var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
        var credential: URLCredential?
        
        //获取服务器发送过来的证书
        let serverTrust:SecTrust = challenge.protectionSpace.serverTrust!
        let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)!
        let remoteCertificateData = CFBridgingRetain(SecCertificateCopyData(certificate))!
        
        //加载本地CA证书
        let cerPath = Bundle.main.path(forResource: "你本地的cer证书文件名", ofType: "cer")!
        let cerUrl = URL(fileURLWithPath:cerPath)
        let localCertificateData = try! Data(contentsOf: cerUrl)
        
        if (remoteCertificateData.isEqual(localCertificateData) == true) {
            
            //服务器证书验证通过
            disposition = URLSession.AuthChallengeDisposition.useCredential
            credential = URLCredential(trust: serverTrust)
            
        } else {
            
            //服务器证书验证失败
            disposition = URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge
            
        }
        
        return (disposition, credential)
        
    }
    
    //发送客户端证书交由服务器验证
    static private func sendClientCer() -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        
        let disposition = URLSession.AuthChallengeDisposition.useCredential
        var credential: URLCredential?
        
        //获取项目中P12证书文件的路径
        let path: String = Bundle.main.path(forResource: "你本地的p12证书文件名", ofType: "p12")!
        let PKCS12Data = NSData(contentsOfFile:path)!
        let key : NSString = kSecImportExportPassphrase as NSString
        let options : NSDictionary = [key : "p12证书的密码"] //客户端证书密码
        
        var items: CFArray?
        let error = SecPKCS12Import(PKCS12Data, options, &items)
        
        if error == errSecSuccess {
            
            let itemArr = items! as Array
            let item = itemArr.first!
            
            let identityPointer = item["identity"];
            let secIdentityRef = identityPointer as! SecIdentity
            
            let chainPointer = item["chain"]
            let chainRef = chainPointer as? [Any]
            
            credential = URLCredential.init(identity: secIdentityRef, certificates: chainRef, persistence: URLCredential.Persistence.forSession)
            
        }
        
        return (disposition, credential)
        
    }
    
}


let loggerPlugin = NetworkLoggerPlugin.init()
let logPlugin = NetLogPlugin.init()
let vipPlugin = VipPlugin.init()
let paramsPlugin = DefaultParamsPlugin.init()
let netDebugPlugin = NetDebugPlugin.init()

let albumProvider = MoyaProvider<WGAlbumTarget>(plugins: [netDebugPlugin, paramsPlugin, logPlugin, vipPlugin, loggerPlugin])
let orderProvider = MoyaProvider<WGOrderTargetApi>(plugins: [netDebugPlugin, paramsPlugin, logPlugin, vipPlugin, loggerPlugin])

public class NetCancellable: NSObject {
    
    let cancellable: Cancellable
    
    init(cancellable: Cancellable) {
        self.cancellable = cancellable
    }
    
    @objc public func cancle() {
        self.cancellable.cancel()
    }
    
    
}

public class NetLayer: NSObject {
    public typealias HeadersClosure = (String) -> [String: String]?
    public typealias CallbackClosure = (_ data: WGConnectData) -> Void
    @objc public static let net: NetLayer = NetLayer.init()
    public private(set) var defaultHeades: [String: String]?
    public private(set) var defaultParams: [String: Any]?
    public private(set) var netDebugValue: String?
    
    private override init() {
        super.init()
        albumProvider.manager.delegate.sessionDidReceiveChallenge = {(session , change) in
            return self.trustServer(challenge: change)
        }
    }
    
  
    @discardableResult
    @objc public func orderRequst(path: String, params: [String: Any]?, callback: @escaping CallbackClosure) -> NetCancellable {
        let cancelable = orderProvider.request(WGOrderTargetApi.init(params: params ?? [String: Any](), path: path)) { (result) in
            switch result {
            case let .success(response):
                callback(self.handleResponse(response))
            case let .failure(error):
                callback(self.handleError(error))
            }
        }
        return NetCancellable.init(cancellable: cancelable)
    }
    
    @discardableResult
    @objc public func albumRequst(path: String, params: [String: Any]?, callback: @escaping CallbackClosure) -> NetCancellable {
        let cancelable = albumProvider.request(WGAlbumTarget.init(params: params ?? [String: Any](), path: path)) { (result) in
            switch result {
            case let .success(response):
                callback(self.handleResponse(response))
            case let .failure(error):
                callback(self.handleError(error))
            }
        }
        return NetCancellable.init(cancellable: cancelable)
    }
    
}

extension NetLayer {
    //不做任何验证，直接信任服务器
    private func trustServer(challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        let disposition = URLSession.AuthChallengeDisposition.useCredential
        let credential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
        return (disposition, credential)
        
    }
}

//MARK: -- Handler result
extension NetLayer {
    private func handleResponse(_ response: Response) -> WGConnectData {
        let data = WGConnectData.init()
        return data
    }
    
    private func handleError(_ error: MoyaError) -> WGConnectData {
        let data = WGConnectData.init()
        data.errType = .kConnect_Unknow_Error_Type
        switch error {
        case let .underlying(urlError, _):
            if let _urlError = urlError as? URLError {
                if _urlError.errorCode == URLError.timedOut.rawValue {
                    data.errType = .kConnect_TimeOut_Error_Type
                }
            }
        default:
            print("")
        }
        return data
    }
}

//MARK: -- DefaultParams
extension NetLayer {
    
    @objc public func configDefaultHeaders(_ headers: [String: String]) {
        defaultHeades = headers
    }
    
    @objc public func configDefaultParams(_ params: [String: Any]) {
        defaultParams = params
    }
    
}


public enum NetErrorType: Int {
    case kConnect_none
    case kConnect_Unknow_Error_Type
    case kConnect_Local_Error_Type
    case kConnect_Serve_Error_Type
    case kConnect_TimeOut_Error_Type
    case kConnect_QiNiu_Error_Type
}

@objcMembers
public class WGConnectData: NSObject {
    
    var errcode: Int?
    var errmsg: String?
    var status: Int?
    var totalPage: Int?
    var responseData: Any?
    var isSuccess: Bool = false
    var errType: NetErrorType = .kConnect_none
    var uid: String?
    var redirect_url: String?
    
    override init() {
        super.init()
    }
}

extension URLRequest {
    func copyRequest(_ request: URLRequest) -> URLRequest {
        var req = URLRequest.init(url: request.url!, cachePolicy: request.cachePolicy, timeoutInterval: request.timeoutInterval)
        req.httpMethod = request.httpMethod
        req.allHTTPHeaderFields = request.allHTTPHeaderFields
        return req
    }
}
