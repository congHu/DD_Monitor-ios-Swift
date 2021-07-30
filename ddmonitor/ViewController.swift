//
//  ViewController.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/16.
//

import UIKit
import Alamofire

var AppBgColor = UIColor(red: 49.0/255.0, green: 54.0/255.0, blue: 59.0/255.0, alpha: 1) //31363b
//var AppHlColor = UIColor(red: 49.0/255.0, green: 54.0/255.0, blue: 59.0/255.0, alpha: 1) //31363b
//var AppPrimaryColor = UIColor(red: 49.0/255.0, green: 54.0/255.0, blue: 59.0/255.0, alpha: 1) //31363b

class ViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var navbar: UINavigationBar!
    var toolbar: UIView!
    var rightToolbar: UIView!
    var ddLayout: DDLayout!
    var upListView: UPListView!
    
    var hdBtn: UIButton!
    var sleepBtn: UIButton!
    
    var globalVolume: Float = 1

    var cancelDragView: UIView!
    var cancelDragLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppBgColor
        
//        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // Do any additional setup after loading the view.
        navbar = UINavigationBar()
        view.addSubview(navbar)
        navbar.backgroundColor = AppBgColor
        
        toolbar = UIView()
        navbar.addSubview(toolbar)

        cancelDragView = UIView()
        cancelDragView.backgroundColor = .systemBlue
        cancelDragView.alpha = 0
        view.addSubview(cancelDragView)
        
        cancelDragLabel = UILabel()
        cancelDragLabel.textColor = .white
        cancelDragLabel.text = "取消拖动"
        cancelDragLabel.textAlignment = .center
        cancelDragView.addSubview(cancelDragLabel)
        
        rightToolbar = UIView()
        toolbar.addSubview(rightToolbar)
        
        
        let refreshBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        refreshBtn.setTitle("\u{e618}", for: .normal)
        refreshBtn.setTitleColor(.white, for: .normal)
        refreshBtn.titleLabel?.font = UIFont(name: "iconfont", size: 18)
        toolbar.addSubview(refreshBtn)
        refreshBtn.addTarget(self, action: #selector(refreshBtnClick), for: .touchUpInside)
        
        let volumeBtn = UIButton(frame: CGRect(x: 40, y: 0, width: 40, height: 40))
        volumeBtn.setTitle("\u{e606}", for: .normal)
        volumeBtn.setTitleColor(.white, for: .normal)
        volumeBtn.titleLabel?.font = UIFont(name: "iconfont", size: 20)
        toolbar.addSubview(volumeBtn)
        volumeBtn.addTarget(self, action: #selector(volumeBtnClick), for: .touchUpInside)
        
        let danmuBtn = UIButton(frame: CGRect(x: 80, y: 0, width: 40, height: 40))
        danmuBtn.setTitleColor(.white, for: .normal)
        danmuBtn.setTitle("\u{e696}", for: .normal)
        danmuBtn.titleLabel?.font = UIFont(name: "iconfont", size: 20)
        toolbar.addSubview(danmuBtn)
        danmuBtn.addTarget(self, action: #selector(danmuBtnClick), for: .touchUpInside)
        
        hdBtn = UIButton(frame: CGRect(x: 120, y: 0, width: 40, height: 40))
        hdBtn.setTitleColor(.white, for: .normal)
        hdBtn.setTitle("画质", for: .normal)
        hdBtn.titleLabel?.font = .systemFont(ofSize: 14)
        toolbar.addSubview(hdBtn)
        hdBtn.addTarget(self, action: #selector(hdBtnClick), for: .touchUpInside)
        
        
       let aboutBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
       aboutBtn.setTitle("\u{e69d}", for: .normal)
       aboutBtn.setTitleColor(.white, for: .normal)
       aboutBtn.titleLabel?.font = UIFont(name: "iconfont", size: 20)
       rightToolbar.addSubview(aboutBtn)
       aboutBtn.addTarget(self, action: #selector(aboutBtnClick), for: .touchUpInside)
        
        sleepBtn = UIButton(frame: CGRect(x: 40, y: 0, width: 60, height: 40))
        sleepBtn.setTitle("\u{e645}", for: .normal)
        sleepBtn.setTitleColor(.white, for: .normal)
        sleepBtn.titleLabel?.font = UIFont(name: "iconfont", size: 20)
        rightToolbar.addSubview(sleepBtn)
        sleepBtn.addTarget(self, action: #selector(sleepBtnClick), for: .touchUpInside)
        
        var landscapeBtn = 100
        print("!=mac", UIDevice.current.userInterfaceIdiom != .mac)
        
        #if !targetEnvironment(macCatalyst)
            landscapeBtn = 140
            let lockLandsacpeBtn = UIButton(frame: CGRect(x: 100, y: 0, width: 40, height: 40))
            lockLandsacpeBtn.setTitle("\u{e664}", for: .normal)
            lockLandsacpeBtn.setTitleColor(.white, for: .normal)
            lockLandsacpeBtn.titleLabel?.font = UIFont(name: "iconfont", size: 20)
            rightToolbar.addSubview(lockLandsacpeBtn)
            lockLandsacpeBtn.addTarget(self, action: #selector(lockLandscapeBtnClick), for: .touchUpInside)
        #endif
        
        let layoutBtn = UIButton(frame: CGRect(x: landscapeBtn, y: 0, width: 40, height: 40))
        layoutBtn.setTitle("\u{ebe5}", for: .normal)
        layoutBtn.setTitleColor(.white, for: .normal)
        layoutBtn.titleLabel?.font = UIFont(name: "iconfont", size: 18)
        rightToolbar.addSubview(layoutBtn)
        layoutBtn.addTarget(self, action: #selector(layoutBtnClick), for: .touchUpInside)
        
        let uplistBtn = UIButton(frame: CGRect(x: 40 + landscapeBtn + 4, y: 4, width: 32, height: 32))
        uplistBtn.setTitle("DD", for: .normal)
        uplistBtn.setTitleColor(AppBgColor, for: .normal)
        uplistBtn.backgroundColor = .white
        uplistBtn.layer.cornerRadius = 16
        rightToolbar.addSubview(uplistBtn)
        uplistBtn.addTarget(self, action: #selector(upListBtnClick), for: .touchUpInside)
        
        ddLayout = DDLayout()
        view.addSubview(ddLayout)
        
        upListView = UPListView()
        view.addSubview(upListView)
        
        if let gVol = UserDefaults.standard.object(forKey: "globalVolume") as? Float {
            globalVolume = gVol
        }else{
            UserDefaults.standard.setValue(globalVolume, forKey: "globalVolume")
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if let showAlert = UserDefaults.standard.object(forKey: "showAlert") as? Bool, showAlert {
//            
//        }else{
//            UserDefaults.standard.setValue(true, forKey: "showAlert")
//            aboutBtnClick()
//        }
    }
    
    @objc func orientationChanged() {
//        print(UIDevice.current.orientation == .landscapeLeft, UIDevice.current.orientation == .landscapeRight)
        viewWillLayoutSubviews()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        viewWillLayoutSubviews()
    }

    var mainLeft:CGFloat = 0
    var mainRight:CGFloat = 0
    var navTop:CGFloat = 0
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navbar.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.bounds.width, height: 40)
//        print(UIDevice.current.orientation == .landscapeLeft, UIDevice.current.orientation == .landscapeRight)
        mainLeft = UIDevice.current.orientation == .landscapeLeft ? view.safeAreaInsets.left : 0
        mainRight = UIDevice.current.orientation == .landscapeRight ? view.safeAreaInsets.right : 0
        
        toolbar.frame = CGRect(x: view.safeAreaInsets.left, y: 0, width: view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: navbar.frame.height)

        cancelDragView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.safeAreaInsets.top+40)
        cancelDragLabel.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.bounds.width, height: 40)
        
        var rightBtns:CGFloat = 180
        #if !targetEnvironment(macCatalyst)
            rightBtns = 220
        #endif
        
        rightToolbar.frame = CGRect(x: toolbar.frame.width - rightBtns, y: 0, width: rightBtns, height: 40)
        
        navTop = view.safeAreaInsets.top + navbar.frame.height
        
        ddLayout.frame = CGRect(x: mainLeft, y: navTop, width: view.bounds.width - mainLeft - mainRight, height: view.bounds.height-navTop-view.safeAreaInsets.bottom)
        upListView.frame = ddLayout.frame
    }
    
    @objc func refreshBtnClick() {
        ddLayout.players.forEach { (p) in
            p.setRoomId(p.roomId)
        }
    }
    
    @objc func volumeBtnClick() {
        let vc = VolumeViewController()
        vc.modalPresentationStyle = .formSheet
        present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    @objc func danmuBtnClick() {
        let vc = DanmuOptionsViewController()
        vc.modalPresentationStyle = .formSheet
        present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    @objc func hdBtnClick() {
        let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for qn in QnNames.keys.sorted(by: { (a, b) -> Bool in
            return Int(a) ?? 0 > Int(b) ?? 0
        }) {
            actionsheet.addAction(UIAlertAction(title: QnNames[qn], style: .default, handler: { (act) in
                for i in 0..<self.ddLayout.numeratePlayer {
                    self.ddLayout.players[i].qn = qn
                    self.ddLayout.players[i].hdBtn.setTitle(QnNames[qn], for: .normal)
                    self.ddLayout.players[i].setRoomId(self.ddLayout.players[i].roomId)
                    UserDefaults.standard.setValue(self.ddLayout.players[i].qn, forKey: "qn\(self.ddLayout.players[i].id)")
                }
                
            }))
        }
        actionsheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        if let pop = actionsheet.popoverPresentationController {
            pop.sourceView = hdBtn
            pop.sourceRect = hdBtn.bounds
        }
        present(actionsheet, animated: true, completion: nil)
    }
    
    @objc func aboutBtnClick() {
        // · 点击右上角“UP”按钮添加UP主，长按拖动到播放器窗口内。\n· 观看多个直播时请注意带宽网速、流量消耗、电池电量、机身发热、系统卡顿等软硬件环境问题。\n· 本软件开源，遵循LGPL-2.1协议。\n· 本软件仅读取公开API数据，不涉及账号登录，欢迎查看源码进行监督。因此，本软件不支持弹幕互动、直播打赏等功能，若要使用请前往原版B站APP。\n· 直播流、UP主信息、以及个人公开的关注列表数据来自B站公开API，最终解释权归B站所有。
        let alret = UIAlertController(title: "DD监控室Swift", message: "CongHu v1.2.0", preferredStyle: .alert)
        // alret.addAction(UIAlertAction(title: "开源地址", style: .default, handler: { (act) in
        //     UIApplication.shared.open(URL(string: "https://github.com/congHu/DD_Monitor-Universal-Swift")!, options: [:], completionHandler: nil)
        // }))
        alret.addAction(UIAlertAction(title: "关闭", style: .cancel, handler: nil))
        present(alret, animated: true, completion: nil)
    }
    
    var autoSleepMinute = 0
    var sleepTimer: Timer?
    func setAutoSleep(_ min: Int) {
        sleepTimer?.invalidate()
        autoSleepMinute = min
        
        sleepBtn.setTitle("\u{e645}", for: .normal)
        
        if autoSleepMinute <= 0 {
            return
        }
        
        sleepBtn.setTitle("\u{e645}\(autoSleepMinute)", for: .normal)
        
        sleepTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (timer) in
            self.autoSleepMinute -= 1
            self.sleepBtn.setTitle("\u{e645}\(self.autoSleepMinute)", for: .normal)
            if self.autoSleepMinute == 0 {
                self.sleepBtn.setTitle("\u{e645}", for: .normal)
                timer.invalidate()
                UIApplication.shared.isIdleTimerDisabled = false
                for p in self.ddLayout.players {
                    p.player?.pause()
                }
            }
        })
    }
    @objc func sleepBtnClick() {
        let alert = UIAlertController(title: "定时关闭", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "15分钟", style: .default, handler: { (act) in
            self.setAutoSleep(15)
        }))
        alert.addAction(UIAlertAction(title: "30分钟", style: .default, handler: { (act) in
            self.setAutoSleep(30)
        }))
        alert.addAction(UIAlertAction(title: "60分钟", style: .default, handler: { (act) in
            self.setAutoSleep(60)
        }))
        alert.addAction(UIAlertAction(title: "自定义", style: .default, handler: { (act) in
            let alert1 = UIAlertController(title: "定时关闭", message: "单位：分钟", preferredStyle: .alert)
            alert1.addTextField { (tf) in
                tf.keyboardType = .numberPad
            }
            alert1.addAction(UIAlertAction(title: "确定", style: .default, handler: { (act) in
                if let min = Int(alert1.textFields?[0].text ?? ""), min > 0 && min <= 99 {
                    self.setAutoSleep(min)
                }else{
                    let alert2 = UIAlertController(title: "无效的时间参数", message: nil, preferredStyle: .alert)
                    alert2.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert2, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(alert1, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "取消定时", style: .default, handler: { (act) in
            self.setAutoSleep(0)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        if let pop = alert.popoverPresentationController {
            pop.sourceView = sleepBtn
            pop.sourceRect = sleepBtn.bounds
        }
        present(alert, animated: true, completion: nil)
    }
    
    @objc func lockLandscapeBtnClick() {
        if (!lockLandscape) {
            UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            lockLandscape = true
        }else{
            lockLandscape = false
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
    
    @objc func layoutBtnClick() {
        let vc = LayoutViewController()
        vc.modalPresentationStyle = .formSheet
        present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    @objc func upListBtnClick() {
        upListView.toggleAnimate()
    }
    
    var lockLandscape = false
    override var shouldAutorotate: Bool {
//        return !lockLandscape
        return !lockLandscape
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return lockLandscape ? .landscape : .all
    }
    
    func addFromClip(_ clip: String, url: URL) {
        let alert = UIAlertController(title: "尝试解析剪贴板的分享链接？", message: clip, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "是", style: .default, handler: { act in
            AF.request(url, headers: [.accept("*/*"),.userAgent("PythonRequests")]).responseString { res in
                switch res.result {
                case .success(let data):
                    print("b23.tv", data)
                    if let regex = try? NSRegularExpression(pattern: "\"room_id\":(\\d+)", options: []) {
                        let res = regex.matches(in: data, options: [], range: NSMakeRange(0, data.count))
                        if res.count > 0 {
                            let roomId = (data as NSString).substring(with: res[0].range(at: 1))
                            if !self.upListView.uplist.contains(roomId) {
                                self.upListView.loadInfo(roomId: roomId) { realRoomId in
                                    if let real = realRoomId {
                                        if !self.upListView.uplist.contains(roomId) {
                                            DispatchQueue.main.async {
                                                self.upListView.showAnimate()
                                                self.upListView.uplist.insert(real, at: 0)
                                                self.upListView.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
                                                UserDefaults.standard.setValue(self.upListView.uplist, forKey: "uplist")
                                            }
                                        }else{
                                            DispatchQueue.main.async {
                                                self.upListView.showAnimate()
                                            }
                                        }
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.upListView.showAnimate()
                                }
                            }
                        }
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        let erralert = UIAlertController(title: "尝试解析失败", message: nil, preferredStyle: .alert)
                        erralert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(erralert, animated: true, completion: nil)
                    }
                    break
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "否", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
//    var panView: UIView?
//    func addPanView(_ panView: UIView, ges: UILongPressGestureRecognizer) {
//        self.panView = panView
//        ddLayout.addSubview(panView)
//        panView.center = ges.location(in: ddLayout)
//        ges.removeTarget(ges.view, action: #selector(UPListCell.doLongPress(_:)))
//        ges.addTarget(self, action: #selector(panViewGesture(_:)))
//
//    }
//
//    @objc func panViewGesture(_ ges: UIPanGestureRecognizer) {
////        pan.view?.center = pan.location(in: view)
//
//
//    }
}
