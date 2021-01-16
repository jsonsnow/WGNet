//
//  WGBaseTargetAPI.swift
//  WGNet
//
//  Created by chen liang on 2021/1/15.
//

import Foundation
import Moya

public class ApiPath {
    let path: String!
    init(path: String) {
        self.path = path
    }
}

let urlParam = [String: Any]()

@objc open class WGBaseTargetAPI: NSObject {
    public typealias ParamsClosure = (String) -> [String: Any]
    public typealias BaseUrlClosure = (String) -> String

    let baseUrlClosure: BaseUrlClosure
    var apiPath: String
    let paramsClosure: ParamsClosure
    
    @objc public init(paramsClosure: @escaping ParamsClosure,baseUrlClosure: @escaping BaseUrlClosure,  path: String) {
        self.paramsClosure = paramsClosure
        self.baseUrlClosure = baseUrlClosure
        self.apiPath = path
    }
}

extension WGBaseTargetAPI: TargetType {
    
    public var baseURL: URL {
        return URL.init(string: baseUrlClosure(type(of: self).description()))!
    }

    public var path: String {
        return apiPath
    }

    public var method: Moya.Method {
        return .post
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }

    public var sampleData: Data {
        return Data.init()
    }

    public var headers: [String : String]? {
        return nil
    }


    public var task: Task {
        let params = paramsClosure(type(of: self).description())
        return .requestCompositeParameters(bodyParameters: params, bodyEncoding: URLEncoding.init(destination: .httpBody, arrayEncoding: .brackets, boolEncoding: .numeric), urlParameters: urlParam)
    }
    
}

