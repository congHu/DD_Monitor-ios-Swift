//
//  DDPlayer.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/17.
//

import UIKit
import AVKit
import Alamofire
import SwiftyJSON
import Starscream

let QnNames = ["10000":"原画","400":"蓝光","250":"超清","150":"高清","80":"流畅"]

class DDPlayer: UIControl, WebSocketDelegate {
    
    var id: Int = -1
    
    var qn = "80"
    
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var loadingView: UIActivityIndicatorView!
    
    var danmuView: UITextView!
    var interpreterView: UITextView!
    
    var danmuOptions: DanmuOption!
    
    var controlBar: UIView!
    var volumeBar: UIView!
    
    var hdBtn: UIButton!
    
    var muteBtn: UIButton!
    var volumeSlider: UISlider!
    
    var nameBtn: UIButton!
    
    var roomId: String?
    
    var cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    
    var socket: WebSocket?
    
    var volumePopup: UIAlertController!
    var volumeLabel: UILabel!
    
    init(id: Int) {
        super.init(frame: .zero)
//        layer.borderWidth = 1
//        layer.borderColor = UIColor.white.cgColor
        self.id = id
        backgroundColor = .black
        
//        let playerItem = AVPlayerItem(url: URL(string: ""))
        
        mainVC = (UIApplication.shared.delegate as! AppDelegate).mainVC
        
        controlBar = UIView()
        controlBar.backgroundColor = UIColor(white: 0, alpha: 0.6)
        controlBar.alpha = 0
        addSubview(controlBar)
        
        let refreshBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        refreshBtn.setTitleColor(.white, for: .normal)
        refreshBtn.setTitle("\u{e618}", for: .normal)
        refreshBtn.titleLabel?.font = UIFont(name: "iconfont", size: 18)
        controlBar.addSubview(refreshBtn)
        refreshBtn.addTarget(self, action: #selector(refreshBtnClick), for: .touchUpInside)
        
        let volumeBtn = UIButton(frame: CGRect(x: 30, y: 0, width: 30, height: 30))
        volumeBtn.setTitleColor(.white, for: .normal)
        volumeBtn.setTitle("\u{e606}", for: .normal)
        volumeBtn.titleLabel?.font = UIFont(name: "iconfont", size: 20)
        controlBar.addSubview(volumeBtn)
        volumeBtn.addTarget(self, action: #selector(volumeBtnClick), for: .touchUpInside)
        
        let danmuBtn = UIButton(frame: CGRect(x: 60, y: 0, width: 30, height: 30))
        danmuBtn.setTitleColor(.white, for: .normal)
        danmuBtn.setTitle("\u{e696}", for: .normal)
        danmuBtn.titleLabel?.font = UIFont(name: "iconfont", size: 20)
        controlBar.addSubview(danmuBtn)
        danmuBtn.addTarget(self, action: #selector(danmuBtnClick), for: .touchUpInside)
        
        hdBtn = UIButton(frame: CGRect(x: 90, y: 0, width: 40, height: 30))
        hdBtn.setTitleColor(.white, for: .normal)
        hdBtn.setTitle("流畅", for: .normal)
        hdBtn.titleLabel?.font = .systemFont(ofSize: 13)
        controlBar.addSubview(hdBtn)
        hdBtn.addTarget(self, action: #selector(hdBtnClick), for: .touchUpInside)
        
        nameBtn = UIButton()
        nameBtn.setTitle("#\(id+1): 空", for: .normal)
        nameBtn.setTitleColor(.white, for: .normal)
        nameBtn.contentHorizontalAlignment = .left
//        nameBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        nameBtn.titleLabel?.lineBreakMode = .byTruncatingTail
        nameBtn.titleLabel?.font = .systemFont(ofSize: 16)
        controlBar.addSubview(nameBtn)
        nameBtn.addTarget(self, action: #selector(nameBtnClick), for: .touchUpInside)
        
        
        
//        let menu = UIMenu(title: "adsf", image: nil, identifier: nil, options: .destructive, children: [
//            UIDeferredMenuElement { complete in
//                complete([UIAction(title: "111", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .mixed, handler: { (act) in
//                    print("111")
//                })])
//            }
//        ])
//        nameBtn.menu = menu
        nameBtn.addAction(UIAction(title: "111", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .mixed, handler: { (act) in
            print("111")
        }), for: .menuActionTriggered)
        nameBtn.showsMenuAsPrimaryAction = true
        
        
        volumeBar = UIView()
        volumeBar.backgroundColor = UIColor(white: 0, alpha: 0.6)
        volumeBar.alpha = 0
        addSubview(volumeBar)
        
        muteBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        muteBtn.setTitleColor(.label, for: .normal)
        muteBtn.setTitle("\u{e607}", for: .normal)
        muteBtn.titleLabel?.font = UIFont(name: "iconfont", size: 22)
        volumeBar.addSubview(muteBtn)
        muteBtn.addTarget(self, action: #selector(muteBtnClick), for: .touchUpInside)
        
        volumeSlider = UISlider()
        volumeSlider.value = 1
        volumeSlider.addTarget(self, action: #selector(volumeSliderChanged), for: .valueChanged)
        volumeSlider.addTarget(self, action: #selector(volumeSliderDown), for: .touchDown)
        volumeSlider.addTarget(self, action: #selector(volumeSliderUp), for: .touchUpInside)
        volumeSlider.addTarget(self, action: #selector(volumeSliderUp), for: .touchUpOutside)
        volumeBar.addSubview(volumeSlider)
        
        volumeLabel = UILabel()
        volumeLabel.text = "100"
        volumeLabel.textAlignment = .center
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(doLongPress(_:)))
        addGestureRecognizer(longpress)
        
//        addTarget(self, action: #selector(playerTap), for: .touchUpInside)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playerTap)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(playerDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        if let vol = UserDefaults.standard.object(forKey: "volume\(id)") as? Float {
//            volume = vol
            volumeSlider.value = vol
            volumeLabel.text = "\(Int(vol * 100))"
        }else{
            UserDefaults.standard.setValue(volumeSlider.value, forKey: "volume\(id)")
        }
        
        loadingView = UIActivityIndicatorView(style: .large)
        addSubview(loadingView)
        loadingView.alpha = 0
        loadingView.startAnimating()
        
        danmuView = UITextView()
        danmuView.textColor = .white
        danmuView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        danmuView.isEditable = false
        danmuView.isSelectable = false
        danmuView.layoutManager.allowsNonContiguousLayout = false
        
        addSubview(danmuView)
        
        interpreterView = UITextView()
        interpreterView.textColor = .white
        interpreterView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        interpreterView.isEditable = false
        interpreterView.isSelectable = false
        interpreterView.layoutManager.allowsNonContiguousLayout = false
        
        addSubview(interpreterView)
        
        
        if let opts = UserDefaults.standard.object(forKey: "danmu\(id)") as? [String:Any] {
            danmuOptions = DanmuOption(dict: opts)
        }else{
            danmuOptions = DanmuOption()
            if UIDevice.current.userInterfaceIdiom != .phone {
                danmuOptions.fontSize = 16
            }
        }
        
//        danmuView.font = .systemFont(ofSize: danmuOptions.fontSize)
//        interpreterView.font = .systemFont(ofSize: danmuOptions.fontSize)
        setDanmuOptions(danmuOptions)
        
        if let qn = UserDefaults.standard.string(forKey: "qn\(id)") {
            self.qn = qn
            hdBtn.setTitle(QnNames[qn], for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = self.frame
        controlBar.frame = CGRect(x: 0, y: frame.height-30, width: frame.width, height: 30)
        volumeBar.frame = CGRect(x: 30, y: frame.height-60, width: frame.width-30 > 150 ? 150 : frame.width-30, height: 30)
//        volumeSlider.frame = CGRect(x: 30, y: 0, width: volumeBar.frame.width-30, height: 30)
        nameBtn.frame = CGRect(x: 130, y: 0, width: controlBar.frame.width-120, height: 30)
        
        loadingView.center = CGPoint(x: frame.width/2, y: frame.height/2)
        
        var danmuViewOrigin = CGPoint(x: 0, y: 0)
        if danmuOptions.position == .rightTop || danmuOptions.position == .rightBottom {
            danmuViewOrigin.x = frame.width - frame.width*danmuOptions.width
        }
        if danmuOptions.position == .leftBottom || danmuOptions.position == .rightBottom {
            danmuViewOrigin.y = frame.height - frame.height*danmuOptions.height
        }
        
        danmuView.frame = CGRect(origin: danmuViewOrigin, size: CGSize(width: frame.width*danmuOptions.width, height: frame.height*danmuOptions.height*(danmuOptions.interpreterStyle == .show ? 0.5 : 1)))
        interpreterView.frame = CGRect(x: danmuViewOrigin.x, y: danmuViewOrigin.y + (danmuOptions.interpreterStyle == .show ? danmuView.frame.height : 0), width: danmuView.frame.width, height: danmuView.frame.height)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var controlBarTimer: Timer?
    @objc func playerTap() {
        if controlBar.alpha == 0 {
            showControlBar()
        }else{
            controlBar.alpha = 0
            volumeBar.alpha = 0
        }
    }
    
    func showControlBar() {
        controlBarTimer?.invalidate()
        controlBar.alpha = 1
        volumeBar.alpha = 0
        bringSubviewToFront(controlBar)
        controlBarTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
            self.controlBar.alpha = 0
        }
    }
    
    @objc func playerDoubleTap() {
        print("doubletap")
        mainVC?.ddLayout.toggleFullLayout(id)
        if let navbar = mainVC?.navbar {
            mainVC?.view.bringSubviewToFront(navbar)
        }
        
    }
    
    @objc func refreshBtnClick() {
        setRoomId(roomId)
    }
    
    @objc func volumeBtnClick() {
//        if volumeBar.alpha == 0 {
//            bringSubviewToFront(volumeBar)
//            volumeBar.alpha = 1
//            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
//                if !self.isVolumeSliderDown {
//                    self.volumeBar.alpha = 0
//                }
//            }
//        }else{
//            volumeBar.alpha = 0
//        }
        volumePopup = UIAlertController(title: nameBtn.title(for: .normal), message: "\n\n\n\n", preferredStyle: .actionSheet)
        
        var sliderWidth:CGFloat = 180
        if UIDevice.current.userInterfaceIdiom == .phone, let m = mainVC {
            sliderWidth = 250
        }
        
        muteBtn.frame = CGRect(x: 20, y: 80, width: 30, height: 30)
        volumePopup.view.addSubview(muteBtn)
        
        volumeSlider.frame = CGRect(x: 50, y: 80, width: sliderWidth, height: 30)
        volumePopup.view.addSubview(volumeSlider)
        
        volumeLabel.frame = CGRect(x: 50+sliderWidth, y: 80, width: 30, height: 30)
        volumePopup.view.addSubview(volumeLabel)
        
        
        volumePopup.addAction(UIAlertAction(title: "关闭", style: .cancel, handler: nil))
        if let pop = volumePopup.popoverPresentationController {
            pop.sourceView = hdBtn
            pop.sourceRect = hdBtn.bounds
        }
        mainVC?.present(volumePopup, animated: true, completion: nil)
    }
    
    func setVolume(_ vol: Float) {
//        volume = vol
        volumeSlider.value = vol
        if let p = player {
            p.volume = volumeSlider.value * (mainVC?.globalVolume ?? 1)
        }
    }
    
    func toggleMute() -> Bool {
//        volume = mute ? 0 : 0.5
        volumeSlider.value = volumeSlider.value > 0 ? 0 : 0.5
        volumeLabel.text = "\(Int(volumeSlider.value * 100))"
        if let p = player {
            p.volume = volumeSlider.value * (mainVC?.globalVolume ?? 1)
        }
        UserDefaults.standard.setValue(volumeSlider.value, forKey: "volume\(id)")
        
        
        return volumeSlider.value == 0
    }
    
//    var isMute = false
//    var volume: Float = 1
    
    var isVolumeSliderDown = false
    
    @objc func muteBtnClick() {
//        if volumeSlider.value > 0 {
//            volumeSlider.value = 0
//        }else{
//            volumeSlider.value = volume * (mainVC?.globalVolume ?? 1)
//        }
//
//        if let p = player, p.volume > 0 {
//            p.volume = 0
//        }
        
        _ = toggleMute()
        
    }
    
    @objc func volumeSliderChanged() {
//        volume = volumeSlider.value
        
        if let p = player {
            p.volume = volumeSlider.value * (mainVC?.globalVolume ?? 1)
        }
        
        volumeLabel.text = "\(Int(volumeSlider.value * 100))"
    }
    
    @objc func volumeSliderDown() {
        print("volumeSliderDown")
        isVolumeSliderDown = true
    }
    
    @objc func volumeSliderUp() {
        print("volumeSliderUp")
        isVolumeSliderDown = false
        UserDefaults.standard.setValue(volumeSlider.value, forKey: "volume\(id)")
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
            if !self.isVolumeSliderDown {
                self.volumeBar.alpha = 0
            }
        }
    }
    
    @objc func danmuBtnClick() {
//        danmuView.alpha = danmuView.alpha == 0 ? 1 : 0
        let vc = DanmuOptionsViewController(id: id)
        vc.modalPresentationStyle = .formSheet
        mainVC?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    @objc func hdBtnClick() {
        let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for qn in QnNames.keys.sorted(by: { (a, b) -> Bool in
            return Int(a) ?? 0 > Int(b) ?? 0
        }) {
            actionsheet.addAction(UIAlertAction(title: QnNames[qn], style: .default, handler: { (act) in
                self.qn = qn
                self.hdBtn.setTitle(QnNames[qn], for: .normal)
                self.setRoomId(self.roomId)
                UserDefaults.standard.setValue(self.qn, forKey: "qn\(self.id)")
            }))
        }
        actionsheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        if let pop = actionsheet.popoverPresentationController {
            pop.sourceView = hdBtn
            pop.sourceRect = hdBtn.bounds
        }
        mainVC?.present(actionsheet, animated: true, completion: nil)
    }
    
    @objc func nameBtnClick() {
        if let roomid = roomId {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "复制id \(roomid)", style: .default, handler: { (act) in
                UIPasteboard.general.string = roomid
            }))
            if _2333 {
                alert.addAction(UIAlertAction(title: "跳转直播间", style: .default, handler: { (act) in
                    let openurl = URL(string: "bilibili://live/\(roomid)")!
                    let weburl = URL(string: "https://live.bilibili.com/\(roomid)")!
                    if UIApplication.shared.canOpenURL(openurl) {
                        UIApplication.shared.open(openurl, options: [:], completionHandler: nil)
                    }else{
                        UIApplication.shared.open(weburl, options: [:], completionHandler: nil)
                    }
                }))
            }
            
            alert.addAction(UIAlertAction(title: "关闭窗口", style: .destructive, handler: { (act) in
                self.setRoomId(nil)
                UserDefaults.standard.setValue(nil, forKey: "roomId\(self.id)")
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            if let pop = alert.popoverPresentationController {
                pop.sourceView = self.nameBtn
                pop.sourceRect = self.nameBtn.bounds
            }
            (UIApplication.shared.delegate as! AppDelegate).mainVC.present(alert, animated: true, completion: nil)
        }

        
    }
    
    func setDanmuOptions(_ opts: DanmuOption) {
        danmuOptions = opts
        
        danmuView.font = .systemFont(ofSize: danmuOptions.fontSize)
        interpreterView.font = .systemFont(ofSize: danmuOptions.fontSize)
        
        if danmuOptions.interpreterStyle == .hide {
            danmuView.alpha = danmuOptions.isShow ? 1 : 0
            interpreterView.alpha = 0
        }
        if danmuOptions.interpreterStyle == .showOnly {
            danmuView.alpha = 0
            interpreterView.alpha = danmuOptions.isShow ? 1 : 0
        }
        if danmuOptions.interpreterStyle == .show {
            danmuView.alpha = danmuOptions.isShow ? 1 : 0
            interpreterView.alpha = danmuOptions.isShow ? 1 : 0
        }
        
        var danmuViewOrigin = CGPoint(x: 0, y: 0)
        if danmuOptions.position == .rightTop || danmuOptions.position == .rightBottom {
            danmuViewOrigin.x = frame.width - frame.width*danmuOptions.width
        }
        if danmuOptions.position == .leftBottom || danmuOptions.position == .rightBottom {
            danmuViewOrigin.y = frame.height - frame.height*danmuOptions.height
        }
        
        danmuView.frame = CGRect(origin: danmuViewOrigin, size: CGSize(width: frame.width*danmuOptions.width, height: frame.height*danmuOptions.height*(danmuOptions.interpreterStyle == .show ? 0.5 : 1)))
        interpreterView.frame = CGRect(x: danmuViewOrigin.x, y: danmuViewOrigin.y + (danmuOptions.interpreterStyle == .show ? danmuView.frame.height : 0), width: danmuView.frame.width, height: danmuView.frame.height)
        
        UserDefaults.standard.setValue(danmuOptions.serialized(), forKey: "danmu\(id)")
    }
    
    
    var panView: UIImageView?
    var mainVC: ViewController?
    @objc func doLongPress(_ ges: UILongPressGestureRecognizer) {
        if roomId == nil {
            return
        }
        
        if ges.state == .began {
            print("longpress")
            
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
            panView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            if let cachePath = self.cachePath {
                panView?.image = UIImage(contentsOfFile: "\(cachePath)/face\(roomId!).png")
            }
            
            panView?.contentMode = .scaleAspectFill
            panView?.backgroundColor = .white
            panView?.layer.cornerRadius = 30
            panView?.clipsToBounds = true
            
            
            mainVC?.view.addSubview(panView!)
            panView?.center = ges.location(in: mainVC?.view)
        }
        
        if ges.state == .changed {
            panView?.center = ges.location(in: mainVC?.view)
            if let p = panView, let m = mainVC, p.center.x < m.view.frame.width - UPTableViewWidth - m.mainRight {
                m.upListView.hideAnimate()
            }
        }
        
        if ges.state == .ended {
            if var p = panView?.center, let m = mainVC {
                if !m.upListView.isShow {
                    p.x -= m.mainLeft
                    p.y -= m.navTop
                    
//                    if let oldRoomId = m.ddLayout.getRoomId(at: p) {
//                        if oldRoomId != roomId! {
//                            m.ddLayout.setRoomId(at: p, roomId: roomId!)
//                            setRoomId(oldRoomId)
//                        }
//                    }else{
//                        m.ddLayout.setRoomId(at: p, roomId: roomId!)
//                        setRoomId(nil)
//                    }
                    
                    if let player2 = m.ddLayout.getPlayer(at: p), player2 != self {
                        let superview1 = superview as? UIStackView
                        let superview2 = player2.superview as? UIStackView
                        
                        removeFromSuperview()
                        player2.removeFromSuperview()
                        
                        superview1?.addArrangedSubview(player2)
                        superview2?.addArrangedSubview(self)
                        
                        m.ddLayout.players[id] = player2
                        m.ddLayout.players[player2.id] = self
                        
                        player2.nameBtn.setTitle(player2.nameBtn.title(for: .normal)?.replacingOccurrences(of: "#\(player2.id+1)", with: "#\(id+1)"), for: .normal)
                        nameBtn.setTitle(nameBtn.title(for: .normal)?.replacingOccurrences(of: "#\(id+1)", with: "#\(player2.id+1)"), for: .normal)
                        
                        
                        let p2id = player2.id
                        player2.id = id
                        id = p2id
                        
                        let p2vol = player2.volumeSlider.value
                        player2.setVolume(volumeSlider.value)
                        setVolume(p2vol)
                        
                        UserDefaults.standard.setValue(roomId, forKey: "roomId\(id)")
                        UserDefaults.standard.setValue(player2.roomId, forKey: "roomId\(player2.id)")
                        
                        UserDefaults.standard.setValue(danmuOptions.serialized(), forKey: "danmu\(id)")
                        UserDefaults.standard.setValue(player2.danmuOptions.serialized(), forKey: "danmu\(player2.id)")
                    }
                    
                    
                }
            }
            panView?.removeFromSuperview()
        }
        
    }

    func setRoomId(_ roomId: String?) {
        self.roomId = roomId
        player?.pause()
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerLayer?.removeFromSuperlayer()
        
        socket?.disconnect()
        socketTimer?.invalidate()
        
        player = nil
        playerItem = nil
        playerLayer = nil
        socket = nil
        socketTimer = nil
        
        loadingView.alpha = 0
        nameBtn.setTitle("#\(id+1): 空", for: .normal)
        
        if roomId == nil {
            return
        }
//        danmuView.clearDanmu()
        danmuView.text = ""
        
        bringSubviewToFront(loadingView)
        loadingView.alpha = 1
        nameBtn.setTitle("#\(id+1): 加载..", for: .normal)
        
        
        
        if !_2333 {
            danmuView.text = "正在连接\n"
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
                self.nameBtn.setTitle("#\(self.id+1): (离线)CAM\(roomId!)", for: .normal)
                
                if self.roomId == "1213262" {
                    self.danmuView.text += "\n连接成功\n"
                    self.nameBtn.setTitle("#\(self.id+1): CAM\(roomId!)", for: .normal)
                    
//                    self.playerItem = AVPlayerItem(url: Bundle.main.url(forResource: "1", withExtension: "mov")!)
                    self.playerItem = AVPlayerItem(url: Bundle.main.url(forResource: "1", withExtension: "mov")!)
                    
                    self.player = AVPlayer(playerItem: self.playerItem)
                    self.playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
                    
                    self.playerLayer = AVPlayerLayer(player: self.player)
                    self.layer.addSublayer(self.playerLayer!)
                    
                    self.playerLayer!.frame = self.frame
                    
                    self.player?.volume = self.volumeSlider.value
                    self.bringSubviewToFront(self.danmuView)
                    self.bringSubviewToFront(self.interpreterView)
                }
            }
            return
        }
        
        AF.request("https://api.live.bilibili.com/xlive/web-room/v1/index/getInfoByRoom?room_id=\(roomId!)").responseJSON { (res) in
            switch res.result {
            case .success(let data):
                let jo = JSON(data)
                
                let realRoomId = jo["data"]["room_info"]["room_id"].int
                if realRoomId == nil {
                    return
                }
                let isLive = jo["data"]["room_info"]["live_status"].intValue == 1
                let liveStatus = isLive ? "" : "(离线)"
                let uname = jo["data"]["anchor_info"]["base_info"]["uname"].string ?? ""
                if var faceImageUrl = jo["data"]["anchor_info"]["base_info"]["face"].string {
                    if faceImageUrl.starts(with: "http://") {
                        faceImageUrl = faceImageUrl.replacingOccurrences(of: "http://", with: "https://")
                    }
                    AF.request(faceImageUrl).responseData { (res) in
                        if case .success(let data) = res.result {
                            if UIImage(data: data) != nil {
                                if let cachePath = self.cachePath {
                                    _ = try? data.write(to: URL(fileURLWithPath: "\(cachePath)/face\(roomId!).png"))
                                }
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.nameBtn.setTitle("#\(self.id+1): \(liveStatus)\(uname)", for: .normal)
                    if !isLive {
                        self.loadingView.alpha = 0
                    }
                }
                
                AF.request("https://api.live.bilibili.com/room/v1/Room/playUrl?cid=\(self.roomId!)&platform=h5&qn=\(self.qn)").responseJSON { (res) in
                    switch res.result {
                    case .success(let data):
                        let jo = JSON(data)
                        
                        if let urlstr = jo["data"]["durl"][0]["url"].string, let url = URL(string: urlstr) {
                            DispatchQueue.main.async {
                                self.playerItem = AVPlayerItem(url: url)
                                
                                self.player = AVPlayer(playerItem: self.playerItem)
                                self.playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
                                
                                self.playerLayer = AVPlayerLayer(player: self.player)
                                self.layer.addSublayer(self.playerLayer!)
                                
                                self.playerLayer!.frame = self.frame
                                
                                self.player?.volume = self.volumeSlider.value
                                self.bringSubviewToFront(self.danmuView)
                                self.bringSubviewToFront(self.interpreterView)
                            }
                        }
                        
                        self.socket = WebSocket(request: URLRequest(url: URL(string: "wss://broadcastlv.chat.bilibili.com/sub")!))
                        self.socket?.delegate = self
                        self.socket?.connect()
                        
                        break
                    case .failure(_):
                        break
                    }
                }
                
                break
            case .failure(_):
                break
            }
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let p = self.playerItem, p.isEqual(object) && keyPath == "status" {
            if p.status == .readyToPlay {
                print("readyToPlay")
                self.loadingView.alpha = 0
                self.player?.play()
            }
        }
    }
    
    var socketTimer: Timer?
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(_):
            let reqStr = "{\"roomid\":\(roomId!)}"
            var data = Data([
                0,0,0,UInt8(reqStr.count)+16,
                0,16,0,1,
                0,0,0,7,
                0,0,0,1
            ])
            data.append(reqStr.data(using: .utf8)!)
            client.write(data: data)
            client.write(data: Data([0,0,0,16,0,16,0,1,0,0,0,2,0,0,0,1]))
            socketTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { (timer) in
                client.write(data: Data([0,0,0,16,0,16,0,1,0,0,0,2,0,0,0,1]))
            })
            break
        case .binary(let data):
            if data[7] == 2 {
//                print("data7==2", data.count)
//                if let unzipped = data[16..<data.count].inflate() {
//                    print("inflate")
//                    print(String(data: unzipped, encoding: .utf8))
//                }
                let (unzipped,err) = InflateStream().write([UInt8](data[16..<data.count]), flush: true)
                if err == nil {
//                    print(String(data: Data(unzipped), encoding: .utf8))
                    var len = 0
                    while len < unzipped.count {
                        let nextLen = Int(unzipped[len+2])*256 + Int(unzipped[len+3])
                        if let jstr = String(data: Data(unzipped[len+16..<len+nextLen]), encoding: .utf8) {
                            let jo = JSON(parseJSON: jstr)
                            if let joCmd = jo["cmd"].string, joCmd == "DANMU_MSG", let danmu = jo["info"][1].string {
//                                print("danmu", roomId, jo["info"][1].string)
                                
                                
                                
                                let splits = self.danmuOptions.interpreterChars.components(separatedBy: " ")
                                var isInterpreterDanmu = false
                                for s in splits {
                                    if s != "" && danmu.starts(with: s) {
                                        isInterpreterDanmu = true
                                        break
                                    }
                                }
                                
                                
                                
                                DispatchQueue.main.async {
                                    var danmuTextList = self.danmuView.text.components(separatedBy: "\n")
                                    if danmuTextList.count > 40 {
                                        danmuTextList.removeSubrange(0..<2)
                                    }
                                    danmuTextList.append(contentsOf: ["", danmu])
                                    self.danmuView.text = danmuTextList.joined(separator: "\n")
//                                    if self.danmuView.contentSize.height > self.danmuView.frame.height {
//                                        self.danmuView.setContentOffset(CGPoint(x: 0, y: self.danmuView.contentSize.height - self.danmuView.frame.height), animated: true)
//                                    }
                                    self.danmuView.scrollRangeToVisible(NSRange(location: self.danmuView.text.count, length: 1))
                                    
                                    if isInterpreterDanmu {
                                        var interpreterTextList = self.interpreterView.text.components(separatedBy: "\n")
                                        if interpreterTextList.count > 40 {
                                            interpreterTextList.removeSubrange(0..<2)
                                        }
                                        interpreterTextList.append(contentsOf: ["", danmu])
                                        self.interpreterView.text = interpreterTextList.joined(separator: "\n")
                                        
                                        self.interpreterView.scrollRangeToVisible(NSRange(location: self.interpreterView.text.count, length: 1))
                                    }
                                }
                            }
                        }
                        len += nextLen
                    }
                }
            }
            break
        case .error(_):
            break
        case .disconnected(_, _):
            print("disconenct",roomId)
            break
        default:
            break
        }
    }
}
