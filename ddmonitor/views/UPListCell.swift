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
    var inPlayer: DDPlayer?
    @objc func doLongPress(_ ges: UILongPressGestureRecognizer) {
        
        if ges.state == .began {
            print("longpress")
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            panView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            panView?.image = cardView.faceImage.image
            panView?.contentMode = .scaleAspectFill
            panView?.backgroundColor = .white
            panView?.layer.cornerRadius = 40
            panView?.clipsToBounds = true
            
            mainVC = (UIApplication.shared.delegate as! AppDelegate).mainVC
            
            mainVC?.view.addSubview(panView!)
            
            mainVC?.cancelDragView.alpha = 1
            mainVC?.cancelDragView.backgroundColor = .systemBlue
            
            mainVC?.upListView.hideAnimate()

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

                if let player = m.ddLayout.getPlayer(at: p.center) {
                    if player != inPlayer {
                        inPlayer = player
                        player.showControlBar()
                    }
                }else{
                    inPlayer = nil
                }
                
                if m.cancelDragView.frame.contains(p.center) {
                    m.cancelDragView.backgroundColor = .systemTeal
                }else{
                    m.cancelDragView.backgroundColor = .systemBlue
                }
            }
        }
        
        if ges.state == .ended {
            if var p = panView?.center, let m = mainVC {
                if !m.cancelDragView.frame.contains(p) {
                    p.x -= m.mainLeft
                    p.y -= m.navTop
                    m.ddLayout.setRoomId(at: p, roomId: roomId)
                }
//                if !m.upListView.isShow {
//                }
                
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
