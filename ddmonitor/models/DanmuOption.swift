//
//  DanmuOption.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/20.
//

import UIKit

enum DanmuPosition: Int {
    case leftTop = 0
    case leftBottom = 1
    case rightTop = 2
    case rightBottom = 3
}

enum DanmuInterpreterStyle: Int {
    case show = 1
    case hide = 0
    case showOnly = 2
}

class DanmuOption: NSObject {
    var isShow: Bool = true
    var fontSize: CGFloat = 13
    var position: DanmuPosition = .leftTop
    var width: CGFloat = 0.2
    var height: CGFloat = 0.8
    var interpreterStyle: DanmuInterpreterStyle = .hide
    var interpreterChars: String = "【 [ {"
    
    func serialized() -> [String:Any] {
        return [
            "isShow": isShow,
            "fontSize": fontSize,
            "position": position.rawValue,
            "width": width,
            "height": height,
            "interpreterStyle": interpreterStyle.rawValue,
            "interpreterChars": interpreterChars
        ]
    }
    
    override init() {
        super.init()
    }
    
    init(dict: [String:Any]) {
        super.init()
        for (k,v) in dict {
            if k == "isShow" {
                isShow = (v as? Bool) ?? true
            }
            if k == "fontSize" {
                fontSize = (v as? CGFloat) ?? 13
            }
            if k == "position" {
                position = DanmuPosition(rawValue: (v as? Int) ?? 0) ?? .leftTop
            }
            if k == "width" {
                width = (v as? CGFloat) ?? 0.2
            }
            if k == "height" {
                height = (v as? CGFloat) ?? 0.8
            }
            if k == "interpreterStyle" {
                interpreterStyle = DanmuInterpreterStyle(rawValue: (v as? Int) ?? 0) ?? .hide
            }
            if k == "interpreterChars" {
                interpreterChars = (v as? String) ?? "【 [ {"
            }
        }
    }
}
