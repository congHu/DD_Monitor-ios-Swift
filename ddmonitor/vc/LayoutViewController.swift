//
//  LayoutViewController.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/20.
//

import UIKit

class LayoutViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let layouts: [[String:Any]] = [
        [:],
        ["o":1,"c":2],
        ["c":2],
        ["c":3],
        
        ["o":1,"c":3],
        ["o":1,"c":[["w":2],["c":2]]],
        ["c":[["w":2],["o":1,"c":2]]],
        ["c":[["o":1,"c":2],["o":1,"c":2]]],
        
        ["c":4],
        ["o":1,"c":[["w":3],["c":3]]],
        ["c":[["w":3],["o":1,"c":3]]],
        ["c":[["o":1,"c":3],["o":1,"c":3]]],
        
        ["o":1,"c":[["w":2,"c":[["w":2],["o":1,"c":2]]],["c":3]]],
        ["c":[["o":1,"c":4],["o":1,"c":4]]],
        ["o":1,"c":[["w":3,"c":[["w":3],["o":1,"c":3]]],["c":4]]],
        ["c":[["o":1,"c":3],["o":1,"c":3],["o":1,"c":3]]],
        
        ["c":[["w":2],[:],[:]]],
        ["c":[[:],["w":2],[:]]],
        ["c":[[:],[:],["w":2]]],
        
        ["o":1,"c":[["w":2,"c":2],["c":3],["c":3]]],
        
        ["c":[["o":1,"c":2],["o":1,"c":2],["w":2],["w":2]]],
        ["c":[["w":2],["o":1,"c":2],["o":1,"c":2],["w":2]]],
        ["c":[["w":2],["w":2],["o":1,"c":2],["o":1,"c":2]]],
        
        ["c":[["w":2],["o":1,"c":2],["o":1,"c":2],["o":1,"c":2],["o":1,"c":2]]],
        ["c":[["o":1,"c":2],["o":1,"c":2],["w":2],["o":1,"c":2],["o":1,"c":2]]],
        ["c":[["o":1,"c":2],["o":1,"c":2],["o":1,"c":2],["o":1,"c":2],["w":2]]],
        
        ["c":[["o":1,"c":2],["o":1,"c":2],["o":1,"c":2],["o":1,"c":2]]]
    ]
    
    var images: [UIImageView] = []
    
    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
        layout.itemSize = CGSize(width: view.bounds.width/4, height: view.bounds.width/4/316*178)
//        layout.estimatedItemSize = CGSize(width: view.bounds.width/4, height: view.bounds.width/4/316*178)
        
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        for i in 1...layouts.count {
            let img = UIImageView()
            img.image = UIImage(named: "layout\(i)")
            img.contentMode = .scaleAspectFill
            images.append(img)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var mainVC: ViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "更改布局"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .done, target: self, action: #selector(closeBtnClick))
        // Do any additional setup after loading the view.
        mainVC = (UIApplication.shared.delegate as! AppDelegate).mainVC
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "layout")
        
        collectionView.backgroundColor = AppBgColor
    }
    
    @objc func closeBtnClick() {
        dismiss(animated: true, completion: nil)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        viewWillLayoutSubviews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let mainLeft = UIDevice.current.orientation == .landscapeLeft ? view.safeAreaInsets.left : 0
        let mainRight = UIDevice.current.orientation == .landscapeRight ? view.safeAreaInsets.right : 0
        collectionView.frame = CGRect(x: mainLeft, y: 0, width: view.frame.width-mainLeft-mainRight, height: view.frame.height)
//        collectionView.reloadData()
        
        // 单元格数量固定而且比较少，就先这么处理
        for im in images {
            im.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width/4, height: collectionView.frame.width/4/316*178)
        }
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width/4, height: collectionView.bounds.width/4/316*178)
    }
    
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "layout", for: indexPath )
        
        cell.addSubview(images[indexPath.row])
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        if let m = mainVC {
            UserDefaults.standard.setValue(layouts[indexPath.row], forKey: "layout")
            m.ddLayout.setLayout(DDLayoutData.loadDict(layouts[indexPath.row]))
            dismiss(animated: true, completion: nil)
        }
        
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
