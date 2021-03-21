//
//  UPCollectionCell.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/21.
//

import UIKit

class UPCollectionCell: UICollectionViewCell {
    
    var cardView: UPCellView!
    var checkMark: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        cardView = UPCellView(frame: CGRect(origin: .zero, size: frame.size))
        addSubview(cardView)
        
        checkMark = UIImageView(image: .checkmark)
        checkMark.frame = CGRect(x: frame.width - 28, y: 2, width: 26, height: 26)
        addSubview(checkMark)
        checkMark.alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
