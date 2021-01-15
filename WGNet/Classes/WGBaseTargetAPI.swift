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


@objc open class WGBaseTargetAPI: NSObject {
    public typealias BaseParamsClosure = (String) -> [String: Any]
    public typealias BaseHeadersClosure = (String) -> [String: String]?
    public typealias BaseUrlClosure = (String) -> String
    let commonParamsClosure: BaseParamsClosure
    let commonHeadersClosure: BaseHeadersClosure
    let baseUrlClosure: BaseUrlClosure
    var apiPath: ApiPath!
    @objc public init(paramsClosure: @escaping BaseParamsClosure, headerClosure: @escaping BaseHeadersClosure, baseUrlClosure: @escaping BaseUrlClosure) {
        self.commonParamsClosure = paramsClosure
        self.commonHeadersClosure = headerClosure
        self.baseUrlClosure = baseUrlClosure
    }
}

extension WGBaseTargetAPI: TargetType {
    public var baseURL: URL {
        URL.init(string: self.baseUrlClosure(type(of: self).description()))!
    }

    public var path: String {
        return apiPath.path
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
        return commonHeadersClosure(type(of: self).description())
    }


    public var task: Task {
        return .requestParameters(parameters: commonParamsClosure(type(of: self).description()), encoding: URLEncoding.default)
    }
}

