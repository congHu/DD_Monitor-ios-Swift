//
//  DDLayout.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/16.
//

import UIKit

class DDLayout: UIStackView {
    var players:[DDPlayer] = []
    
    var ddLayoutData: DDLayoutData?
    
    
//    var stackview: UIStackView!
    
    init() {
        super.init(frame: CGRect.zero)
        initPlayers()
        
        if let layout = UserDefaults.standard.dictionary(forKey: "layout") {
            setLayout(DDLayoutData.loadDict(layout))
        }else{
            if UIDevice.current.userInterfaceIdiom == .phone {
                setLayout(DDLayoutData.loadDict([
                    "c": 3
                ]))
            }else{
                setLayout(DDLayoutData.loadDict([
                    "o": 1,
                    "c": [
                        ["w":2],
                        ["c":2]
                    ]
                ]))
            }
            
            
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPlayers() {
//        backgroundColor = .black
        
        for i in 0..<9 {
            players.append(DDPlayer(id: i))
        }
        
//        stackview = UIStackView()
//        addSubview(stackview)
        
    }
    
    func setLayout(_ layoutData: DDLayoutData) {
        ddLayoutData = layoutData
        
        for v in arrangedSubviews {
            removeArrangedSubview(v)
        }
        
        if ddLayoutData == nil {
            return
        }
        
//        let oldActivePlayerCount = numeratePlayer
        numeratePlayer = 0
        addStackViews(layoutData: ddLayoutData!, stackView: self)
        
        if numeratePlayer < players.count {
            for i in numeratePlayer..<players.count {
                players[i].setRoomId(nil)
            }
        }
        
//        if numeratePlayer > oldActivePlayerCount {
//            for i in oldActivePlayerCount..<numeratePlayer {
//                if players[i].roomId == nil {
//                    if let savedRoomId = UserDefaults.standard.string(forKey: "roomId\(i)") {
//                        players[i].setRoomId(savedRoomId)
//                    }
//                }
//            }
//        }
        
        for i in 0..<numeratePlayer {
            if players[i].roomId == nil {
                if let savedRoomId = UserDefaults.standard.string(forKey: "roomId\(players[i].id)") {
                    players[i].setRoomId(savedRoomId)
                }
            }
        }
        
        
        
//        stackview.axis = .horizontal
//        stackview.alignment = .fill
//        stackview.distribution = .fill
//
//        let p1 = DDPlayer()
//        stackview.addArrangedSubview(p1)
    }
    
    var numeratePlayer = 0
    func addStackViews(layoutData: DDLayoutData, stackView: UIStackView) {
        stackView.axis = layoutData.orientation == 0 ? .vertical : .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 1
        
        if layoutData.children.count > 1 {
            var childStackView: UIStackView?
            var anchor: NSLayoutDimension?
            var weight:Int = 0
            for c in layoutData.children {
                if childStackView == nil {
                    childStackView = UIStackView()
                    stackView.addArrangedSubview(childStackView!)
                    anchor = layoutData.orientation == 0 ? childStackView!.heightAnchor : childStackView!.widthAnchor
                    weight = c.weight
                }else{
                    let nextChild = UIStackView()
                    stackView.addArrangedSubview(nextChild)
                    let nextAnchor = layoutData.orientation == 0 ? nextChild.heightAnchor : nextChild.widthAnchor
//                    print(CGFloat(c.weight/weight))
                    nextAnchor.constraint(equalTo: anchor!, multiplier: CGFloat(c.weight)/CGFloat(weight)).isActive = true
                    childStackView = nextChild
                    anchor = nextAnchor
                    weight = c.weight
                }
                
                addStackViews(layoutData: c, stackView: childStackView!)
                
            }
        }else{
            stackView.addArrangedSubview(players[numeratePlayer])
            print("numeratePlayer", numeratePlayer)
            numeratePlayer += 1
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        players[0].frame = CGRect(x: 0, y: 0, width: frame.width/2, height: frame.height)
//        players[1].frame = CGRect(x: frame.width/2, y: 0, width: frame.width/2, height: frame.height)
//        stackview.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

//    func playerNum(at point: CGPoint) -> Int {
//        if let d = ddLayoutData, d.children.count > 1 {
//
//        }
//        return 0
//    }
    func setRoomId(at point: CGPoint, roomId: String) {
        for p in players {
            if convert(p.frame, from: p).contains(point) {
                p.setRoomId(roomId)
                UserDefaults.standard.setValue(roomId, forKey: "roomId\(p.id)")
                break
            }
        }
    }
    
    func getPlayer(at point: CGPoint) -> DDPlayer? {
        for p in players {
            if convert(p.frame, from: p).contains(point) {
                return p
            }
        }
        return nil
    }
    
    var fullLayoutId: Int?
    var oldLayout: DDLayoutData?
    func toggleFullLayout(_ id: Int) {
        if let oLayout = oldLayout {
            if let oId = fullLayoutId, oId > 0 {
                let p0 = players[0]
                players[0] = players[oId]
                players[oId] = p0
                fullLayoutId = nil
            }
            setLayout(oLayout)
            oldLayout = nil
        }else{
            oldLayout = ddLayoutData
            
            if id > 0 {
                fullLayoutId = id
                let p0 = players[0]
                players[0] = players[id]
                players[id] = p0
                
                p0.player?.pause()
            }
            setLayout(DDLayoutData())
            
        }
    }
}
