//
//  UPListView.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/19.
//

import UIKit
import Alamofire
import SwiftyJSON

let UPTableViewWidth:CGFloat = 200
let UPTableViewCellHeight:CGFloat = 144

class UPListView: UIView, UITableViewDelegate, UITableViewDataSource {

    var sideView: UIView!
    var tableView: UITableView!
    var blankClickView: UIControl!
    
    var isShow = false
    
    var uplist: [String] = []//["47377","8792912","21652717","47867"]
    
    var upInfos: [String:UPInfo] = [:]
    
    
    var cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    
    init() {
        super.init(frame: .zero)
        
        print(cachePath)
        
        if let ul = UserDefaults.standard.array(forKey: "uplist") as? [String] {
            uplist = ul
        }
//        else{
//            UserDefaults.standard.setValue(uplist, forKey: "uplist")
//        }
        
        alpha = 0
        
        blankClickView = UIControl()
        blankClickView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        addSubview(blankClickView)
        blankClickView.addTarget(self, action: #selector(hideAnimate), for: .touchUpInside)
        
        sideView = UIView()
        addSubview(sideView)
        
        let titleBar = UIView(frame: CGRect(x: 0, y: 0, width: UPTableViewWidth, height: 44))
        sideView.addSubview(titleBar)
        titleBar.backgroundColor = AppBgColor
        
        let titleView = UILabel(frame: CGRect(x: 16, y: 12, width: 0, height: 28))
        titleView.font = .boldSystemFont(ofSize: 20)
        titleView.textColor = .white
        titleView.text = "列表"
        titleView.sizeToFit()
        titleBar.addSubview(titleView)
        
        let addBtn = UIButton(frame: CGRect(x: titleView.frame.width + 20, y: 8, width: 48, height: 28))
        addBtn.setTitle("添加", for: .normal)
        addBtn.setTitleColor(.white, for: .normal)
        addBtn.titleLabel?.font = .systemFont(ofSize: 14)
        addBtn.layer.cornerRadius = 4
        addBtn.layer.borderWidth = 1
        addBtn.layer.borderColor = UIColor.white.cgColor
        titleBar.addSubview(addBtn)
        addBtn.addTarget(self, action: #selector(addBtnClick), for: .touchUpInside)
        
        let importBtn = UIButton(frame: CGRect(x: titleView.frame.width + 72, y: 8, width: 48, height: 28))
        importBtn.setTitle("导入", for: .normal)
        importBtn.setTitleColor(.white, for: .normal)
        importBtn.titleLabel?.font = .systemFont(ofSize: 14)
        importBtn.layer.cornerRadius = 4
        importBtn.layer.borderWidth = 1
        importBtn.layer.borderColor = UIColor.white.cgColor
        titleBar.addSubview(importBtn)
        importBtn.addTarget(self, action: #selector(importBtnClick), for: .touchUpInside)
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = AppBgColor
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UPListCell.self, forCellReuseIdentifier: "up")
        sideView.addSubview(tableView)
//        tableView.automaticallyAdjustsScrollIndicatorInsets = false
    }
    
    func loadUpList() {
        if let ul = UserDefaults.standard.array(forKey: "uplist") as? [String] {
            uplist = ul
            tableView.reloadData()
        }
//        for roomId in uplist {
//            loadInfo(roomId: roomId, finished: nil)
//        }
        loadManyUpInfo()
    }
    
    func sortUpList() {
        uplist.sort { (a, b) -> Bool in
            if let aa = upInfos[a] {
                return aa.isLive
            }
            return false
        }
    }
    
    func loadInfo(roomId: String, finished: ((String?) -> Void)? ) {
        if !_2333 {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                let upinfo = UPInfo()
                
                upinfo.title = "CAM\(roomId)"
                upinfo.isLive = false
                upinfo.uname = "DDCAM"
                
                if roomId == "1213262" {
                    upinfo.uname = "DDCAMTest"
                    upinfo.isLive = true
                }
                if roomId == "1000101" {
                    upinfo.uname = "CAMLOCAL"
                }
                
                self.upInfos[roomId] = upinfo
                self.tableView.reloadData()
                
                finished?(roomId)
            }
            return
        }
        
        AF.request("https://api.live.bilibili.com/xlive/web-room/v1/index/getInfoByRoom?room_id=\(roomId)").responseJSON { (res) in
            switch res.result {
            case .success(let data):
                let jo = JSON(data)
                
                let realRoomId = jo["data"]["room_info"]["room_id"].int
                if realRoomId == nil {
                    finished?(nil)
                    return
                }
                let upinfo = UPInfo()
                
                upinfo.title = jo["data"]["room_info"]["title"].string
                upinfo.coverImageUrl = jo["data"]["room_info"]["keyframe"].string
                upinfo.isLive = jo["data"]["room_info"]["live_status"].intValue == 1
                upinfo.uname = jo["data"]["anchor_info"]["base_info"]["uname"].string
                upinfo.faceImageUrl = jo["data"]["anchor_info"]["base_info"]["face"].string
                
                self.upInfos[roomId] = upinfo
                
                self.sortUpList()
                
                DispatchQueue.main.async {
//                    self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
//                    self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
                    self.tableView.reloadData()
                }
                
                finished?(String(realRoomId!))
                
                if let cachePath = self.cachePath {
                    if let face = UIImage(contentsOfFile: "\(cachePath)/face\(roomId).png") {
                        self.upInfos[roomId]?.coverImage = face
                        DispatchQueue.main.async {
//                            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
//                            self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .fade)
                            self.tableView.reloadData()
                        }
                    }
                    if let cover = UIImage(contentsOfFile: "\(cachePath)/cover\(roomId).png") {
                        self.upInfos[roomId]?.coverImage = cover
                        DispatchQueue.main.async {
//                            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
//                            self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .fade)
                            self.tableView.reloadData()
                        }
                    }
                }
                
                if var coverimg = upinfo.coverImageUrl {
                    if let cachePath = self.cachePath {
                        self.upInfos[roomId]?.coverImage = UIImage(contentsOfFile: "\(cachePath)/cover\(roomId).png")
                        DispatchQueue.main.async {
//                            self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .fade)
                            self.tableView.reloadData()
                        }
                    }
                    if coverimg.starts(with: "http://") {
                        coverimg = coverimg.replacingOccurrences(of: "http://", with: "https://")
                    }
                    AF.request(coverimg).responseData { (res) in
                        if case .success(let data) = res.result {
                            if let img = UIImage(data: data) {
                                self.upInfos[roomId]?.coverImage = img
                                DispatchQueue.main.async {
//                                    self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
//                                    self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .fade)
                                    self.tableView.reloadData()
                                }
                                if let cachePath = self.cachePath {
                                    _ = try? data.write(to: URL(fileURLWithPath: "\(cachePath)/cover\(roomId).png"))
                                }
                            }
                        }
                    }
                }
                if var faceimg = upinfo.faceImageUrl {
                    if let cachePath = self.cachePath {
                        self.upInfos[roomId]?.faceImage = UIImage(contentsOfFile: "\(cachePath)/face\(roomId).png")
                        DispatchQueue.main.async {
//                            self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .fade)
                            self.tableView.reloadData()
                        }
                    }
                    if faceimg.starts(with: "http://") {
                        faceimg = faceimg.replacingOccurrences(of: "http://", with: "https://")
                    }
                    AF.request(faceimg).responseData { (res) in
                        if case .success(let data) = res.result {
                            if let img = UIImage(data: data) {
                                self.upInfos[roomId]?.faceImage = img
                                DispatchQueue.main.async {
//                                    self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
//                                    self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .fade)
                                    self.tableView.reloadData()
                                }
                            }
                            if let cachePath = self.cachePath {
                                _ = try? data.write(to: URL(fileURLWithPath: "\(cachePath)/face\(roomId).png"))
                            }
                        }
                    }
                }
                
                
                
                
                
                break
            case .failure(_):
                break
            }
        }
    }
    
    func loadManyUpInfo() {
        if !_2333 {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                for roomId in self.uplist {
                    let upinfo = UPInfo()
                    
                    upinfo.title = "CAM\(roomId)"
                    upinfo.isLive = false
                    upinfo.uname = "DDCAM"
                    
                    if roomId == "1213262" {
                        upinfo.uname = "DDCAMTest"
                        upinfo.isLive = true
                    }
                    if roomId == "1000101" {
                        upinfo.uname = "CAMLOCAL"
                    }
                    
                    self.upInfos[roomId] = upinfo
                }
                self.tableView.reloadData()
                
            }
            return
        }
        
        let ids = uplist.map({ (s) -> Int in
            return Int(s) ?? 0
        })
        print("ids", ids)
        
        AF.request("https://api.live.bilibili.com/room/v2/Room/get_by_ids",
                   method: .post,
                   parameters: [
                    "ids": ids
                   ],
                   encoder: JSONParameterEncoder.default).responseJSON { (res) in
            switch res.result {
            case .success(let data):
                let jo = JSON(data)
                if let uidData = jo["data"].dictionary {
                    let uids = uidData.values.map { (s) -> Int in
                        return s["uid"].intValue
                    }
                    print("uids", uids)
                    AF.request("https://api.live.bilibili.com/room/v1/Room/get_status_info_by_uids",
                               method: .post,
                               parameters: [
                                "uids": uids
                               ],
                               encoder: JSONParameterEncoder.default
                    ).responseJSON { (res1) in
                        switch res1.result {
                        case .success(let data1):
                            let jo1 = JSON(data1)
                            for (k,v) in jo1["data"] {
                                print(k)
                                if let realRoomId = v["room_id"].int {
                                    let roomId = String(realRoomId)
                                    let upinfo = UPInfo()
                                    
                                    upinfo.title = v["title"].string
                                    upinfo.coverImageUrl = v["keyframe"].string
                                    upinfo.isLive = v["live_status"].intValue == 1
                                    upinfo.uname = v["uname"].string
                                    upinfo.faceImageUrl = v["face"].string
                                    
                                    self.upInfos[roomId] = upinfo
                                    
                                    if let cachePath = self.cachePath {
                                        if let face = UIImage(contentsOfFile: "\(cachePath)/face\(roomId).png") {
                                            self.upInfos[roomId]?.coverImage = face
                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                            }
                                        }
                                        if let cover = UIImage(contentsOfFile: "\(cachePath)/cover\(roomId).png") {
                                            self.upInfos[roomId]?.coverImage = cover
                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                    
                                    if var coverimg = upinfo.coverImageUrl {
                                        if let cachePath = self.cachePath {
                                            self.upInfos[roomId]?.coverImage = UIImage(contentsOfFile: "\(cachePath)/cover\(roomId).png")
                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                            }
                                        }
                                        if coverimg.starts(with: "http://") {
                                            coverimg = coverimg.replacingOccurrences(of: "http://", with: "https://")
                                        }
                                        AF.request(coverimg).responseData { (res) in
                                            if case .success(let data) = res.result {
                                                if let img = UIImage(data: data) {
                                                    self.upInfos[roomId]?.coverImage = img
                                                    DispatchQueue.main.async {
                                                        self.tableView.reloadData()
                                                    }
                                                    if let cachePath = self.cachePath {
                                                        _ = try? data.write(to: URL(fileURLWithPath: "\(cachePath)/cover\(roomId).png"))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    if var faceimg = upinfo.faceImageUrl {
                                        if let cachePath = self.cachePath {
                                            self.upInfos[roomId]?.faceImage = UIImage(contentsOfFile: "\(cachePath)/face\(roomId).png")
                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                            }
                                        }
                                        if faceimg.starts(with: "http://") {
                                            faceimg = faceimg.replacingOccurrences(of: "http://", with: "https://")
                                        }
                                        AF.request(faceimg).responseData { (res) in
                                            if case .success(let data) = res.result {
                                                if let img = UIImage(data: data) {
                                                    self.upInfos[roomId]?.faceImage = img
                                                    DispatchQueue.main.async {
                                                        self.tableView.reloadData()
                                                    }
                                                }
                                                if let cachePath = self.cachePath {
                                                    _ = try? data.write(to: URL(fileURLWithPath: "\(cachePath)/face\(roomId).png"))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            self.sortUpList()
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            break
                        case .failure(_):
                            break
                        }
                    }
                }
                
                
                
                
                
                
                break
            case .failure(_):
                break
            }
        }
    }
    
    @objc func addBtnClick() {
        let alert = UIAlertController(title: "输入key", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (act) in
            if let roomIdInt = Int(alert.textFields?.first?.text ?? "") {
                let roomId = String(roomIdInt)
                if !self.uplist.contains(roomId) {
                    
                    
                    self.loadInfo(roomId: roomId) { realRoomId in
                        DispatchQueue.main.async {
                            if let real = realRoomId {
                                if !self.uplist.contains(real) {
                                    self.uplist.insert(real, at: 0)
                                    self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
                                    UserDefaults.standard.setValue(self.uplist, forKey: "uplist")
                                }
                            }else{
                                let erralert = UIAlertController(title: "查询设备失败", message: nil, preferredStyle: .alert)
                                erralert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                (UIApplication.shared.delegate as! AppDelegate).mainVC.present(erralert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }else{
                let erralert = UIAlertController(title: "无效的key", message: nil, preferredStyle: .alert)
                erralert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                (UIApplication.shared.delegate as! AppDelegate).mainVC.present(erralert, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        (UIApplication.shared.delegate as! AppDelegate).mainVC.present(alert, animated: true, completion: nil)
    }
    
    @objc func importBtnClick() {
        let vc = UidImportViewController()
        vc.modalPresentationStyle = .formSheet
        (UIApplication.shared.delegate as! AppDelegate).mainVC.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blankClickView.frame = CGRect(origin: .zero, size: frame.size)
//        print(frame.width)
        sideView.frame = CGRect(x: frame.width-UPTableViewWidth, y: 0, width: UPTableViewWidth, height: frame.height)
        tableView.frame = CGRect(x: 0, y: 44, width: UPTableViewWidth, height: frame.height-44)
//        tableView.reloadData()
//        tableView.contentInset = UIEdgeInsets.zero
//        tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func toggleAnimate() {
        if isShow {
            hideAnimate()
        }else{
            showAnimate()
        }
    }
    
    func showAnimate() {
        loadUpList()
        isShow = true
        alpha = 1
        
        blankClickView.alpha = 0
        sideView.center.x = frame.width + UPTableViewWidth/2
        
        UIView.animate(withDuration: 0.3) {
            self.blankClickView.alpha = 1
            self.sideView.center.x = self.frame.width - UPTableViewWidth/2
        }
    }
    
    @objc func hideAnimate() {
        isShow = false
        UIView.animate(withDuration: 0.3) {
            self.blankClickView.alpha = 0
            self.sideView.center.x = self.frame.width + UPTableViewWidth/2
        } completion: { (complete) in
            self.alpha = 0
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uplist.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UPTableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "up", for: indexPath) as! UPListCell
        
        let roomid = uplist[indexPath.row]
        
        cell.roomId = roomid
        
        if let info = upInfos[roomid] {
            
            if let uname = info.uname {
                cell.cardView.unameLabel.text = uname
            }else{
                cell.cardView.unameLabel.text = nil
            }
            if let title = info.title {
                cell.cardView.titleLabel.text = title
            }else{
                cell.cardView.titleLabel.text = nil
            }
            if let cover = info.coverImage {
                cell.cardView.coverImage.image = cover
            }else{
                cell.cardView.coverImage.image = nil
            }
            if let face = info.faceImage {
                cell.cardView.faceImage.image = face
            }else{
                cell.cardView.faceImage.image = nil
            }
            if info.isLive {
                cell.cardView.isLiveCover.alpha = 0
            }else{
                cell.cardView.isLiveCover.alpha = 1
                cell.cardView.isLiveCover.text = "离线"
            }
        }else{
            cell.cardView.faceImage.image = nil
            cell.cardView.coverImage.image = nil
            cell.cardView.unameLabel.text = nil
            cell.cardView.titleLabel.text = nil
            cell.cardView.isLiveCover.alpha = 1
            cell.cardView.isLiveCover.text = "加载.."
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let roomid = self.uplist[indexPath.row]
        let alert = UIAlertController(title: "选项", message: "关闭此菜单后，长按卡片可拖动到窗口内", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "复制id \(roomid)", style: .default, handler: { (act) in
            UIPasteboard.general.string = roomid
        }))
        if _2333 {
            alert.addAction(UIAlertAction(title: "跳转", style: .default, handler: { (act) in
                let roomid = self.uplist[indexPath.row]
                let openurl = URL(string: "bilibili://live/\(roomid)")!
                let weburl = URL(string: "https://live.bilibili.com/\(roomid)")!
                if UIApplication.shared.canOpenURL(openurl) {
                    UIApplication.shared.open(openurl, options: [:], completionHandler: nil)
                }else{
                    UIApplication.shared.open(weburl, options: [:], completionHandler: nil)
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { (act) in
            self.uplist.remove(at: indexPath.row)
            self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
            UserDefaults.standard.setValue(self.uplist, forKey: "uplist")
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        if let pop = alert.popoverPresentationController {
            if let cell = self.tableView.cellForRow(at: indexPath) {
                pop.sourceView = cell
                pop.sourceRect = cell.bounds
            }else{
                pop.sourceView = self.tableView
                pop.sourceRect = self.tableView.bounds
            }
        }
        (UIApplication.shared.delegate as! AppDelegate).mainVC.present(alert, animated: true, completion: nil)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
