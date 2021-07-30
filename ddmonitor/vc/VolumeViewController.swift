//
//  VolumeViewController.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/20.
//

import UIKit

class VolumeViewController: UITableViewController {
    
    var mainVC: ViewController?
    var row = 1
    
    var sliders: [UISlider] = []
    var muteBtns: [UIButton] = []
    var volumeLabels: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        mainVC = (UIApplication.shared.delegate as! AppDelegate).mainVC
        if let m = mainVC {
            row = m.ddLayout.numeratePlayer + 1
        }
        
        for i in 0..<row {
            let slider = UISlider()
            slider.tag = i
            slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
            slider.addTarget(self, action: #selector(sliderUp(_:)), for: .touchUpInside)
            slider.addTarget(self, action: #selector(sliderUp(_:)), for: .touchUpOutside)
            sliders.append(slider)
            
            let btn = UIButton(frame: CGRect(x: 100, y: 2, width: 40, height: 40))
            btn.tag = i
            btn.setTitle("\u{e607}", for: .normal)
            btn.setTitleColor(.label, for: .normal)
            btn.titleLabel?.font = UIFont(name: "iconfont", size: 22)
            btn.addTarget(self, action: #selector(muteBtnClick(_:)), for: .touchUpInside)
            muteBtns.append(btn)
            
            let label = UILabel()
            label.tag = i
            label.text = "100"
            label.textAlignment = .center
            volumeLabels.append(label)
        }
        
        title = "音量调节"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .done, target: self, action: #selector(closeBtnClick))
        
//        tableView.register(VolumeControlCell.self, forCellReuseIdentifier: "vol")
        
        tableView.allowsSelection = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
//        let mainLeft = UIDevice.current.orientation == .landscapeLeft ? view.safeAreaInsets.left : 0
//        let mainRight = UIDevice.current.orientation == .landscapeRight ? view.safeAreaInsets.right : 0
        
//        tableView.frame = CGRect(x: view.safeAreaInsets.left, y: 0, width: view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: view.frame.height)
        
        for s in sliders {
            s.frame = CGRect(x: 144, y: 8, width: tableView.frame.width - 244 - view.safeAreaInsets.right, height: 32)
        }
        for l in volumeLabels {
            l.frame = CGRect(x: tableView.frame.width - 70 - view.safeAreaInsets.right, y: 9, width: 30, height: 30)
        }
    }
    
    @objc func closeBtnClick() {
        dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return row
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "vol", for: indexPath) as! VolumeControlCell
        let cell = UITableViewCell(style: .default, reuseIdentifier: "vol")
        
        cell.contentView.addSubview(sliders[indexPath.row])
        cell.contentView.addSubview(muteBtns[indexPath.row])
        cell.contentView.addSubview(volumeLabels[indexPath.row])
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "全局"
            sliders[indexPath.row].value = mainVC?.globalVolume ?? 1
        }else{
            cell.textLabel?.text = "窗口#\(indexPath.row)"
            sliders[indexPath.row].value = mainVC?.ddLayout.players[indexPath.row - 1].volumeSlider.value ?? 1
        }
        volumeLabels[indexPath.row].text = "\(Int(sliders[indexPath.row].value * 100))"
        
        return cell
    }
    
    @objc func sliderChanged(_ slider: UISlider) {
        if let m = mainVC {
            if slider.tag == 0 {
                m.globalVolume = slider.value
                for i in 1..<sliders.count {
                    m.ddLayout.players[i-1].setVolume(sliders[i].value)
                }
            }else{
                m.ddLayout.players[slider.tag-1].setVolume(slider.value)
            }
        }
        volumeLabels[slider.tag].text = "\(Int(slider.value * 100))"
    }
    
    @objc func sliderUp(_ slider: UISlider) {
        if slider.tag == 0 {
            UserDefaults.standard.setValue(slider.value, forKey: "globalVolume")
        }else{
            UserDefaults.standard.setValue(slider.value, forKey: "volume\(slider.tag-1)")
        }
    }
    
    @objc func muteBtnClick(_ btn: UIButton) {
        if let m = mainVC {
            if btn.tag == 0 {
                sliders[btn.tag].value = sliders[btn.tag].value > 0 ? 0 : 0.5
                m.globalVolume = sliders[btn.tag].value
                for i in 1..<sliders.count {
                    m.ddLayout.players[i-1].setVolume(sliders[i].value)
                }
            }else{
                sliders[btn.tag].value = m.ddLayout.players[btn.tag-1].toggleMute() ? 0 : 0.5
            }
            volumeLabels[btn.tag].text = "\(Int(sliders[btn.tag].value * 100))"
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
