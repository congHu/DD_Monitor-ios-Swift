//
//  UPListCell.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/19.
//

import UIKit

class UPListCell: UITableViewCell {

    var cardView: UPCellView!
    
    var roomId: String!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = AppBgColor
        selectionStyle = .none
//        contentView.frame = CGRect(x: 0, y: 0, width: UPTableViewWidth, height: UPTableViewCellHeight)
//        contentView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        
        cardView = UPCellView(frame: CGRect(x: 16, y: 8, width: UPTableViewWidth-32, height: UPTableViewCellHeight-16))
        addSubview(cardView)
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(doLongPress(_:)))
        addGestureRecognizer(longpress)
        
        
    }
    
    var panView: UIImageView?
    var mainVC: ViewController?
    @objc func doLongPress(_ ges: UILongPressGestureRecognizer) {
        
        if ges.state == .began {
            print("longpress")
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            panView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            panView?.image = cardView.faceImage.image
            panView?.contentMode = .scaleAspectFill
            panView?.backgroundColor = .white
            panView?.layer.cornerRadius = 30
            panView?.clipsToBounds = true
            
            mainVC = (UIApplication.shared.delegate as! AppDelegate).mainVC
            mainVC?.view.addSubview(panView!)
            mainVC?.cancelDragView.alpha = 1

            panView?.center = ges.location(in: mainVC?.view)
        }
        
        if ges.state == .changed {
            panView?.center = ges.location(in: mainVC?.view)
            if let p = panView, let m = mainVC {
                // if p.center.x < m.view.frame.width - UPTableViewWidth - m.mainRight && m.upListView.alpha == 1 {
                //     m.upListView.hideAnimate()
                // }
                // if p.center.x > m.view.frame.width - UPTableViewWidth/4 - m.mainRight && m.upListView.alpha == 0 {
                //     m.upListView.showAnimate()
                // }

                // convert(p.frame, from: p)
                if mainVC?.cancelDragView.frame.contains(p) {
                    mainVC?.cancelDragView.backgroundColor = .cyan
                }else{
                    mainVC?.cancelDragView.backgroundColor = .systemBlue
                }
            }
        }
        
        if ges.state == .ended {
            if var p = panView?.center, let m = mainVC {
                if !m.upListView.isShow {
                    p.x -= m.mainLeft
                    p.y -= m.navTop
                    m.ddLayout.setRoomId(at: p, roomId: roomId)
                    
                }
            }
            panView?.removeFromSuperview()

            mainVC?.cancelDragView.alpha = 0
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
