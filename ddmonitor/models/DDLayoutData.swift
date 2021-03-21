//
//  LayoutData.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/17.
//

import UIKit

class DDLayoutData: NSObject {
    override init() {
        super.init()
        
    }
    
    
    static func loadDict(_ dict: [String: Any]) -> DDLayoutData {
        let data = DDLayoutData()
        for (k,v) in dict {
            if k == "o" || k == "orientation" {
                if let o = v as? Int {
                    data.orientation = o
                }
            }
            if k == "w" || k == "weight" {
                if let w = v as? Int {
                    data.weight = w
                }
            }
            if k == "c" || k == "children" {
                if let children = v as? [[String: Any]] {
                    for c in children {
                        data.children.append(DDLayoutData.loadDict(c))
                    }
                }
                if let childrenCount = v as? Int {
                    for _ in 0..<childrenCount {
                        data.children.append(DDLayoutData())
                    }
                }
            }
        }
        return data
    }
    
    var orientation: Int = 0
    
    var weight: Int = 1
    
    var children: [DDLayoutData] = []
    
}
