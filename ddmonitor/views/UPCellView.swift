//
//  UPCellView.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/21.
//

import UIKit

class UPCellView: UIView {

    var coverImage: UIImageView!
    var faceImage: UIImageView!
    var unameLabel: UILabel!
    var titleLabel: UILabel!
    
    var isLiveCover: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        backgroundColor = UIColor(white: 0, alpha: 0.6)
        layer.cornerRadius = 8
        clipsToBounds = true
        
//        addSubview(card)
        
        coverImage = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height - 36))
        coverImage.contentMode = .scaleAspectFill
        coverImage.clipsToBounds = true
        addSubview(coverImage)
        coverImage.backgroundColor = UIColor(white: 0, alpha: 0.6)
        
        isLiveCover = UILabel(frame: coverImage.frame)
        isLiveCover.text = "加载.."
        isLiveCover.textColor = .white
        isLiveCover.textAlignment = .center
        isLiveCover.backgroundColor = UIColor(white: 0, alpha: 0.6)
        addSubview(isLiveCover)
        
        faceImage = UIImageView(frame: CGRect(x: 4, y: coverImage.frame.height+4, width: 28, height: 28))
        faceImage.contentMode = .scaleAspectFill
        faceImage.layer.cornerRadius = 14
        faceImage.clipsToBounds = true
        addSubview(faceImage)
        faceImage.backgroundColor = UIColor(white: 0, alpha: 0.6)
        
        unameLabel = UILabel(frame: CGRect(x: 36, y: coverImage.frame.height+4, width: frame.width-42, height: 15))
        unameLabel.textColor = .white
        unameLabel.font = .systemFont(ofSize: 13)
        addSubview(unameLabel)
//        unameLabel.backgroundColor = UIColor(white: 0, alpha: 0.6)
        
        titleLabel = UILabel(frame: CGRect(x: 36, y: unameLabel.frame.origin.y + unameLabel.frame.height, width: unameLabel.frame.width, height: 13))
        titleLabel.textColor = .gray
        titleLabel.font = .systemFont(ofSize: 11)
        addSubview(titleLabel)
//        titleLabel.backgroundColor = UIColor(white: 0, alpha: 0.6)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
