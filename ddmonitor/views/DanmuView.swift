//
//  DanmuView.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/20.
//

import UIKit

class DanmuView: UITextView {
    
//    var danmuList: [String] = []

    init() {
        super.init(frame: .zero, textContainer: NSTextContainer())
        backgroundColor = UIColor(white: 0, alpha: 0.6)
        
        isEditable = false
        
        text = String()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func addDanmu(_ danmu: String) {
        text.append("\n\(danmu)\n")
        
        
        setContentOffset(CGPoint(x: 0, y: contentSize.height), animated: true)
        
    }
    
    func clearDanmu() {
//        danmuList.removeAll()
//        reloadData()
        
        text = ""
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
