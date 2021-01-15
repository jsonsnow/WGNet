//
//  NetCommonParamsPlugin.swift
//  WGNet
//
//  Created by chen liang on 2021/1/15.
//

import Foundation
import Moya
import Alamofire

public class DefaultParamsPlugin: Moya.PluginType {
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var req = URLRequest.init(url: request.url!, cachePolicy: request.cachePolicy, timeoutInterval: request.timeoutInterval)
         try? Alamofire.JSONEncoding.init().encode(req, with: [String: Any]())
        ///Alamofire.JSONDecoder.init().decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: <#T##Data#>)
        let body = request.httpBody
        return req
    }
    
}
