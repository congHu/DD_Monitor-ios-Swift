//
//  DanmuOptionsViewController.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/20.
//

import UIKit

class DanmuOptionsViewController: UITableViewController {

    var mainVC: ViewController?
    
    var danmuSwitch: UISwitch!
    
    var danmuPosition: UISegmentedControl!
    
    var danmuFontSizeLabel: UILabel!
    var danmuFontSizeStepper: UIStepper!
    
    var danmuWidthStepper: UIStepper!
    var danmuHeightStepper: UIStepper!
    var danmuWidthLabel: UILabel!
    var danmuHeightLabel: UILabel!
    
    var interpreterStyle: UISegmentedControl!
    var interpreterChars: UITextField!
    
    var id: Int?
    
    var danmuOptions: DanmuOption!
    
    init() {
        super.init(style: .plain)
    }
    
    init(id: Int?) {
        super.init(style: .plain)
        self.id = id
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainVC = (UIApplication.shared.delegate as! AppDelegate).mainVC
        
        if id != nil && id! >= 0 && id! < 9 {
            title = _2333 ? "窗口#\(id!+1)弹幕设置" : "窗口#\(id!+1)日志设置"
        }else{
            title = _2333 ? "全局弹幕设置" : "全局日志设置"
        }
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .done, target: self, action: #selector(closeBtnClick))
        
        tableView.keyboardDismissMode = .interactive
        tableView.allowsSelection = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "danmuOptions")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        danmuSwitch = UISwitch()
        danmuSwitch.isOn = true
        danmuSwitch.addTarget(self, action: #selector(danmuSwitchChanged), for: .valueChanged)
        
        danmuPosition = UISegmentedControl(items: ["左上","左下","右上","右下"])
//        danmuPosition.selectedSegmentIndex = 0
        danmuPosition.addTarget(self, action: #selector(danmuPositionChanged), for: .valueChanged)
        
        danmuFontSizeStepper = UIStepper()
        danmuFontSizeStepper.minimumValue = 6
        danmuFontSizeStepper.maximumValue = 32
        danmuFontSizeStepper.value = 13
        danmuFontSizeStepper.addTarget(self, action: #selector(fontSizeChanged), for: .valueChanged)
        
        danmuFontSizeLabel = UILabel()
        danmuFontSizeLabel.text = "13"
        
        danmuWidthStepper = UIStepper()
        danmuWidthStepper.minimumValue = 0.1
        danmuWidthStepper.maximumValue = 1
        danmuWidthStepper.stepValue = 0.1
        danmuWidthStepper.value = 0.2
        danmuWidthStepper.addTarget(self, action: #selector(danmuWidthChanged), for: .valueChanged)
        
        danmuWidthLabel = UILabel()
        danmuWidthLabel.text = "0.2"
        
        danmuHeightStepper = UIStepper()
        danmuHeightStepper.minimumValue = 0.1
        danmuHeightStepper.maximumValue = 1
        danmuHeightStepper.stepValue = 0.1
        danmuHeightStepper.value = 0.8
        danmuHeightStepper.addTarget(self, action: #selector(danmuHeightChanged), for: .valueChanged)
        
        danmuHeightLabel = UILabel()
        danmuHeightLabel.text = "0.8"
        
        interpreterStyle = UISegmentedControl(items: ["关闭","开启","独占"])
        interpreterStyle.addTarget(self, action: #selector(interpreterStyleChnaged), for: .valueChanged)
        
        interpreterChars = UITextField()
        interpreterChars.textAlignment = .right
        interpreterChars.returnKeyType = .done
        interpreterChars.addTarget(self, action: #selector(interpreterCharsEnd), for: .editingDidEnd)
        interpreterChars.addTarget(self, action: #selector(interpreterCharsEnd), for: .editingDidEndOnExit)
        interpreterChars.text = "【 [ {"
        
        if let winId = id, winId >= 0 && winId < 9, let opt = mainVC?.ddLayout.players[winId].danmuOptions {
            danmuOptions = opt
            
            danmuSwitch.isOn = opt.isShow
            danmuPosition.selectedSegmentIndex = opt.position.rawValue
            danmuFontSizeLabel.text = String(format: "%0.0f", opt.fontSize)
            danmuFontSizeStepper.value = Double(opt.fontSize)
            danmuWidthLabel.text = String(format: "%0.1f", opt.width)
            danmuWidthStepper.value = Double(opt.width)
            danmuHeightLabel.text = String(format: "%0.1f", opt.height)
            danmuHeightStepper.value = Double(opt.height)
            
            interpreterStyle.selectedSegmentIndex = opt.interpreterStyle.rawValue
            interpreterChars.text = opt.interpreterChars
        }else{
            danmuOptions = DanmuOption()
            if UIDevice.current.userInterfaceIdiom != .phone {
                danmuOptions.fontSize = 16
            }
        }
    }
    
    @objc func closeBtnClick() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let safeWidth = tableView.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right - 16
        
        danmuSwitch.frame = CGRect(origin: CGPoint(x: safeWidth - danmuSwitch.frame.width, y: 8), size: danmuSwitch.frame.size)
        
        danmuPosition.frame = CGRect(origin: CGPoint(x: safeWidth - danmuPosition.frame.width, y: 6), size: danmuPosition.frame.size)
        
        
        danmuFontSizeStepper.frame = CGRect(origin: CGPoint(x: safeWidth - danmuFontSizeStepper.frame.width, y: 6), size: danmuFontSizeStepper.frame.size)
        danmuFontSizeLabel.frame = CGRect(x: danmuFontSizeStepper.frame.origin.x - 40, y: 8, width: 40, height: 28)
        
        danmuWidthStepper.frame = CGRect(origin: CGPoint(x: safeWidth - danmuWidthStepper.frame.width, y: 6), size: danmuWidthStepper.frame.size)
        danmuWidthLabel.frame = CGRect(x: danmuWidthStepper.frame.origin.x - 40, y: 8, width: 40, height: 28)
        
        danmuHeightStepper.frame = CGRect(origin: CGPoint(x: safeWidth - danmuHeightStepper.frame.width, y: 6), size: danmuHeightStepper.frame.size)
        danmuHeightLabel.frame = CGRect(x: danmuHeightStepper.frame.origin.x - 40, y: 8, width: 40, height: 28)
        
        interpreterStyle.frame = CGRect(origin: CGPoint(x: safeWidth - interpreterStyle.frame.width, y: 6), size: interpreterStyle.frame.size)
        interpreterChars.frame = CGRect(x: safeWidth/2, y: 6, width: safeWidth/2, height: 32)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "danmuOptions", for: indexPath)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "开关"
            cell.contentView.addSubview(danmuSwitch)
            break
        case 1:
            cell.textLabel?.text = "视窗位置"
            cell.contentView.addSubview(danmuPosition)
            break
        case 2:
            cell.textLabel?.text = "字体大小"
            cell.contentView.addSubview(danmuFontSizeLabel)
            cell.contentView.addSubview(danmuFontSizeStepper)
            break
        case 3:
            cell.textLabel?.text = "视窗宽度"
            cell.contentView.addSubview(danmuWidthLabel)
            cell.contentView.addSubview(danmuWidthStepper)
            break
        case 4:
            cell.textLabel?.text = "视窗高度"
            cell.contentView.addSubview(danmuHeightLabel)
            cell.contentView.addSubview(danmuHeightStepper)
            break
        case 5:
            cell.textLabel?.text = "同传"
            cell.contentView.addSubview(interpreterStyle)
            break
        case 6:
            cell.textLabel?.text = "同传过滤"
            cell.contentView.addSubview(interpreterChars)
            break
        default:
            break
        }

        return cell
    }
    
    @objc func danmuSwitchChanged() {
        danmuOptions.isShow = danmuSwitch.isOn
        
        updateOptions()
    }
    
    @objc func danmuPositionChanged() {
        danmuOptions.position = DanmuPosition(rawValue: danmuPosition.selectedSegmentIndex) ?? .leftTop
        updateOptions()
    }
    
    @objc func fontSizeChanged() {
        danmuFontSizeLabel.text = String(format: "%0.0f", danmuFontSizeStepper.value)
        
        danmuOptions.fontSize = CGFloat(danmuFontSizeStepper.value)
        updateOptions()
    }
    
    @objc func danmuWidthChanged() {
        danmuWidthLabel.text = String(format: "%0.1f", danmuWidthStepper.value)
        
        danmuOptions.width = CGFloat(danmuWidthStepper.value)
        updateOptions()
    }
    
    @objc func danmuHeightChanged() {
        danmuHeightLabel.text = String(format: "%0.1f", danmuHeightStepper.value)
        
        danmuOptions.height = CGFloat(danmuHeightStepper.value)
        updateOptions()
    }
    
    @objc func interpreterStyleChnaged() {
        danmuOptions.interpreterStyle = DanmuInterpreterStyle(rawValue: interpreterStyle.selectedSegmentIndex) ?? .hide
        updateOptions()
    }
    
    @objc func interpreterCharsEnd() {
        print("edit end")
        danmuOptions.interpreterChars = interpreterChars.text ?? ""
        updateOptions()
    }
    
    func updateOptions() {
        if let main = mainVC {
            if let winId = id, winId >= 0 && winId < 9 {
                main.ddLayout.players[winId].setDanmuOptions(danmuOptions)
            }else{
                for p in main.ddLayout.players {
                    p.setDanmuOptions(danmuOptions)
                }
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
