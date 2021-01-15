//
//  WGNetLayer.swift
//  WGNet
//
//  Created by chen liang on 2021/1/15.
//

import Foundation
import Moya

let loggerPlugin = NetworkLoggerPlugin.init()
let logPlugin = NetLogPlugin.init()
let vipPlugin = VipPlugin.init()

let albumProvider = MoyaProvider<WGAlbumTarget>(plugins: [logPlugin, vipPlugin, loggerPlugin])
let orderProvider = MoyaProvider<WGOrderTargetApi>(plugins: [logPlugin, vipPlugin, loggerPlugin])

class NetCancellable: NSObject {
    
    let cancellable: Cancellable
    
    init(cancellable: Cancellable) {
        self.cancellable = cancellable
    }
    
    @objc public func cancle() {
        self.cancellable.cancel()
    }
    
    
}

class NetLayer {
    
    @objc public func orderRequst(path: String, params: [String: Any]) -> NetCancellable {
        return NetCancellable.init(cancellable: orderProvider.request(WGOrderTargetApi.init(path: path, params: params)) { (response) in
            
        })
    }
    
    @objc public func albumRequst(path: String, params: [String: Any]) -> NetCancellable {
        return NetCancellable.init(cancellable: albumProvider.request(WGAlbumTarget.init(path: path, params: params)) { (response) in
            
        })
    }
    
}
