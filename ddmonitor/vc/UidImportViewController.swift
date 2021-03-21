//
//  UidImportViewController.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/21.
//

import UIKit
import Alamofire
import SwiftyJSON

class UidImportViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var searchBar: UISearchBar!
    
    var searchResult: [JSON] = []
    
    var noResultLabel: UILabel!
    
    var loadingView: UIActivityIndicatorView!
    
    var imgsInMem: [String: UIImage] = [:]
    
    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
        
//        layout.itemSize = CGSize(width: UPTableViewWidth-32, height: UPTableViewCellHeight-16)
        
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        navigationItem.rightBarButtonItem =
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneBtnClick)),
            UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(closeBtnClick))
            
        ]
        
        searchBar = UISearchBar()
        searchBar.placeholder = "您的B站UID(获取公开关注列表)"
        navigationController?.navigationBar.addSubview(searchBar)
        searchBar.searchTextField.addTarget(self, action: #selector(searchBarEnded), for: .editingDidEndOnExit)
        
        collectionView.keyboardDismissMode = .interactive
        collectionView.backgroundColor = AppBgColor
        
        collectionView.register(UPCollectionCell.self, forCellWithReuseIdentifier: "up")
        
        noResultLabel = UILabel()
        noResultLabel.text = "查询无结果"
        noResultLabel.textColor = .white
        noResultLabel.textAlignment = .center
        collectionView.addSubview(noResultLabel)
        noResultLabel.alpha = 0
        
        loadingView = UIActivityIndicatorView(style: .large)
        collectionView.addSubview(loadingView)
        loadingView.hidesWhenStopped = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        print("viewWillLayoutSubviews")
        searchBar.frame = CGRect(x: view.safeAreaInsets.left + 16, y: 0, width: navigationController!.navigationBar.frame.width - 128 - view.safeAreaInsets.left - view.safeAreaInsets.right, height: navigationController!.navigationBar.frame.height)
        
        let mainLeft = UIDevice.current.orientation == .landscapeLeft ? view.safeAreaInsets.left : 0
        let mainRight = UIDevice.current.orientation == .landscapeRight ? view.safeAreaInsets.right : 0
        collectionView.frame = CGRect(x: mainLeft, y: 0, width: view.frame.width-mainLeft-mainRight, height: view.frame.height)
        
        noResultLabel.frame = CGRect(x: 0, y: 30, width: collectionView.frame.width, height: 30)
        
        loadingView.center = CGPoint(x: collectionView.frame.width/2, y: 40)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    @objc func closeBtnClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func searchBarEnded() {
        print("searchBarEnded")
        
        if let uid = Int(searchBar.text ?? "") {
            searchBar.resignFirstResponder()
            
            searchResult.removeAll()
            midResult.removeAll()
            collectionView.reloadData()
            
            noResultLabel.alpha = 0
            loadingView.startAnimating()
            
            loadMids(uid, pn: 1)
        }
    }
    
    var midResult: [Int] = []
    func loadMids(_ uid: Int, pn: Int) {
        AF.request("https://api.bilibili.com/x/relation/followings?vmid=\(uid)&pn=\(pn)&ps=50&order=desc&jsonp=jsonp").responseJSON { (res) in
            switch res.result {
            case .success(let data):
                let jo = JSON(data)
                if let list = jo["data"]["list"].array, list.count > 0 {
                    for e in list {
                        if let mid = e["mid"].int {
                            self.midResult.append(mid)
                        }
                    }
                    self.loadMids(uid, pn: pn+1)
                }else if self.midResult.count > 0 {
                    self.loadRoomInfo()
                }else{
                    DispatchQueue.main.async {
                        self.loadingView.stopAnimating()
                        self.noResultLabel.alpha = 1
                    }
                }
                break
            case .failure(_):
                DispatchQueue.main.async {
                    self.loadingView.stopAnimating()
                    self.noResultLabel.alpha = 1
                }
                break
            }
        }
    }
    
    func loadRoomInfo() {
        AF.request("https://api.live.bilibili.com/room/v1/Room/get_status_info_by_uids",
                   method: .post,
                   parameters: [
                    "uids": midResult
                   ],
                   encoder: JSONParameterEncoder.default
        ).responseJSON { (res) in
            switch res.result {
            case .success(let data):
                let jo = JSON(data)
                if let mids = jo["data"].dictionary {
                    self.searchResult = Array(mids.values)
                    self.searchResult.sort { (a, b) -> Bool in
                        return a["live_status"].intValue == 1
                    }
                    DispatchQueue.main.async {
                        self.selectedRoomId.removeAll()
                        self.loadingView.stopAnimating()
                        self.collectionView.reloadData()
                    }
                }
                break
            case .failure(_):
                DispatchQueue.main.async {
                    self.loadingView.stopAnimating()
                    self.noResultLabel.alpha = 1
                }
                break
            }
        }
    }
    
//    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
////        print(fromInterfaceOrientation)
////        collectionView.reloadData()
//        collectionViewLayout.invalidateLayout()
//    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        print("sizeForItemAt")
//        let mainLeft = UIDevice.current.orientation == .landscapeLeft ? view.safeAreaInsets.left : 0
//        let mainRight = UIDevice.current.orientation == .landscapeRight ? view.safeAreaInsets.right : 0
        
        var w = (collectionView.frame.width - 32 - 48) / 4
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            w = (collectionView.frame.width - 32 - 48) / 4
            if UIDevice.current.orientation == .portrait {
                w = (collectionView.frame.width - 32 - 16) / 2
            }
        }
        
        
        let h = w / 168 * 128
        return CGSize(width: w, height: h)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "up", for: indexPath) as! UPCollectionCell
//        print("cellForItemAt")
        let info = searchResult[indexPath.row]
        
        
//        if let info = upInfos[roomid] {
//
//
//        }else{
//            cell.cardView.faceImage.image = nil
//            cell.cardView.coverImage.image = nil
//            cell.cardView.unameLabel.text = nil
//            cell.cardView.titleLabel.text = nil
//            cell.cardView.isLiveCover.alpha = 1
//            cell.cardView.isLiveCover.text = "加载.."
//        }
        if let uname = info["uname"].string {
            cell.cardView.unameLabel.text = uname
        }else{
            cell.cardView.unameLabel.text = nil
        }
        if let title = info["title"].string {
            cell.cardView.titleLabel.text = title
        }else{
            cell.cardView.titleLabel.text = nil
        }
        if let cover = info["keyframe"].string {
            if let img = imgsInMem[cover] {
                cell.cardView.coverImage.image = img
            }else{
                cell.cardView.coverImage.image = nil
                AF.request(cover).responseData { (res) in
                    switch res.result {
                    case .success(let data):
                        if let img = UIImage(data: data) {
                            self.imgsInMem[cover] = img
                            DispatchQueue.main.async {
                                cell.cardView.coverImage.image = img
                            }
                        }
                        break
                    case .failure(_):
                        break
                    }
                }
            }
            
        }else{
            cell.cardView.coverImage.image = nil
        }
        if let face = info["face"].string {
            if let img = imgsInMem[face] {
                cell.cardView.faceImage.image = img
            }else{
                cell.cardView.faceImage.image = nil
                AF.request(face).responseData { (res) in
                    switch res.result {
                    case .success(let data):
                        if let img = UIImage(data: data) {
                            self.imgsInMem[face] = img
                            DispatchQueue.main.async {
                                cell.cardView.faceImage.image = img
                            }
                        }
                        break
                    case .failure(_):
                        break
                    }
                }
            }
            
        }else{
            cell.cardView.faceImage.image = nil
        }
        if let isLive = info["live_status"].int, isLive == 1 {
            cell.cardView.isLiveCover.alpha = 0
        }else{
            cell.cardView.isLiveCover.alpha = 1
            cell.cardView.isLiveCover.text = "未开播"
        }
        
        if selectedRoomId.contains(String(info["room_id"].intValue)) {
            cell.checkMark.alpha = 1
        }else{
            cell.checkMark.alpha = 0
        }
        
        return cell
    }
    
    var selectedRoomId: Set = Set<String>()
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        let roomId = String(searchResult[indexPath.row]["room_id"].intValue)
        if selectedRoomId.contains(roomId) {
            selectedRoomId.remove(roomId)
        }else{
            selectedRoomId.insert(roomId)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    @objc func doneBtnClick() {
        if selectedRoomId.isEmpty {
            let alert = UIAlertController(title: "请至少选择一项", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        if var uplist = UserDefaults.standard.array(forKey: "uplist") as? [String] {
            for up in uplist {
                if selectedRoomId.contains(up) {
                    selectedRoomId.remove(up)
                }
            }
            uplist.append(contentsOf: selectedRoomId)
            print(uplist)
            UserDefaults.standard.setValue(uplist, forKey: "uplist")
        }else{
            
        }
        
        (UIApplication.shared.delegate as! AppDelegate).mainVC.upListView.loadUpList()
        
        dismiss(animated: true, completion: nil)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
