//
//  WGAlbumTarget.swift
//  WGNet
//
//  Created by chen liang on 2021/1/15.
//

import UIKit
import Moya

class WGAlbumTarget: WGBaseTargetAPI {
    
    public convenience init(path: String, params:[String: Any]?) {
        self.init(paramsClosure: { (target) -> [String : Any] in
            guard let _params = params else {
                return [String: Any]()
            }
            return _params
        }, headerClosure: { (target) -> [String : String]? in
            return nil
        }) { (target) -> String in
            return "https://www.wsxcme.com/"
        }
    }
}
