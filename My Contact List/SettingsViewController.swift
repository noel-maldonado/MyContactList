//
//  SettingsViewController.swift
//  My Contact List
//
//  Created by Noel Maldonado on 4/1/20.
//  Copyright © 2020 Noel Maldonado. All rights reserved.
//

import UIKit

import CoreMotion

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //second ascending option
    @IBOutlet weak var swAscending2: UISwitch!
    
    @IBOutlet weak var lblBattery: UILabel!
    
    @IBOutlet var settingsView: UIView!
    
    //Sort Order Picker View
    @IBOutlet weak var pckSortField: UIPickerView!
    //Ascending Sort Switch
    @IBOutlet weak var swAscending: UISwitch!
    //Adds array to store items that will show up in the Picker View
    let sortOrderItems: Array<String> = ["contactName", "city", "birthday", "state", "zipCode"]
    
    //Second Sort Order Picker View
    @IBOutlet weak var pckState: UIPickerView!
    //Adds Array for second sorting pick
    let stateItems: Array<String> = ["contactName", "city", "birthday", "state", "zipCode"]
//    let stateItems: Array<String> = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pckSortField.dataSource = self;
        pckSortField.delegate = self;
        pckState.dataSource = self;
        pckState.delegate = self;
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryChanged), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.batteryChanged), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        self.batteryChanged()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //set the UI based on values in UserDefaults
        let settings = UserDefaults.standard
        swAscending.setOn(settings.bool(forKey: Constants.kSortDirectionAscending), animated: true)
        let sortField = settings.string(forKey: Constants.kSortField)
        swAscending2.setOn(settings.bool(forKey: Constants.kSortDirectionAscending2), animated: true)
        var i = 0
        //loops through all the fields in the Sort Order Picker View
        for field in sortOrderItems {
            //if the field selected is User saved preference it is told to select that row
            if field == sortField {
                pckSortField.selectRow(i, inComponent: 0, animated: false)
            }
            i += 1
        }
        pckSortField.reloadComponent(0)
        
        // state default
        let secondField = settings.string(forKey: Constants.kState)
        var f = 0
        for stateItem in stateItems {
            
            if stateItem == secondField {
                pckState.selectRow(f, inComponent: 0, animated: false)
            }
            f += 1
        }
        pckState.reloadComponent(0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Getting information about the device
        self.startMotionDetection()
        
        let device = UIDevice.current
        print("Device Info:")
        print("Name: \(device.name)")
        print("Model: \(device.model)")
        print("System Name: \(device.systemName)")
        print("System Version: \(device.systemVersion)")
        print("Identifier: \(device.identifierForVendor!)")
            
        let orientation: String
        switch (device.orientation) {
        case .faceDown:
            orientation = "Face Down"
        case .landscapeLeft:
            orientation = "Landscape Left"
        case .portrait:
            orientation="Portrait"
        case .landscapeRight:
            orientation = "Landscape Right"
        case .faceUp:
            orientation = "Face Up"
        case .portraitUpsideDown:
            orientation = "Portrait Upside Down"
        case .unknown:
            orientation = "Unknown Orientation"
        }
        print("Orientation: \(orientation)")
    }
        
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIDevice.current.isBatteryMonitoringEnabled = false
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.motionManager.stopAccelerometerUpdates()
    }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
    }
    
    
    //Ascending Sort Switch Action
    @IBAction func sortDirectionChanged(_ sender: Any) {
        let settings = UserDefaults.standard
        settings.set(swAscending.isOn, forKey: Constants.kSortDirectionAscending)
        settings.synchronize()
    }
    
    //Ascending Sort Switch Action 2
    @IBAction func sortDirectionChanged2(_ sender: Any) {
        let settings = UserDefaults.standard
        settings.set(swAscending2.isOn, forKey: Constants.kSortDirectionAscending2)
        settings.synchronize()
    }
    
    
    // MARK: UIPickerViewDelegate Methods
    
    //returns the number of 'columns' to display
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
     }
     
     // returns the # of rows in the picker
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return sortOrderItems.count
        } else {
            return stateItems.count
        }
        
     }
    
    //sets the value that is shown for each row in the picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 { //First PickerView
            return sortOrderItems[row]
        } else { //Second Picker Voew
            return stateItems[row]
        }
    }
    
    
    //if the user choses from the pickerview, it calls this function; print is shown in the console
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        let settings = UserDefaults.standard
        
        
        if pickerView.tag == 1 { //First PickerView
            let sortField = sortOrderItems[row]
            settings.set(sortField, forKey: Constants.kSortField)
            settings.synchronize()
        }else { //second Picker View
            
            let secondField = stateItems[row]
            settings.set(secondField, forKey: Constants.kState)
            settings.synchronize()
        }
        
    }


    @objc func batteryChanged() {
        let device = UIDevice.current
        var batteryState: String
        switch (device.batteryState) {
        case .charging:
            batteryState = "+"
        case .full:
            batteryState = "!"
        case .unplugged:
            batteryState = "-"
        case .unknown:
            batteryState = "?"
        }
        let batteryLevelPercent = device.batteryLevel * 100
        let batteryLevel = String(format: "%.0f%%", batteryLevelPercent)
        let batteryStatus = "\(batteryLevel) \(batteryState)"
        lblBattery.text = batteryStatus
    }
    
    
    func startMotionDetection() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let mManager = appDelegate.motionManager
        if mManager.isAccelerometerAvailable {
            mManager.accelerometerUpdateInterval = 0.05
            mManager.startAccelerometerUpdates(to: OperationQueue.main) {
                (data: CMAccelerometerData?, error: Error?) in self.updateLabel(data: data!)
            }
        }
    }
    
    func updateLabel(data: CMAccelerometerData) {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
               let tabBarHeight = self.tabBarController?.tabBar.frame.height
               let moveFactor:Double = 15.0
               var rect = lblBattery.frame
               let moveToX = Double(rect.origin.x) + data.acceleration.x * moveFactor
               let moveToY = Double(rect.origin.y + rect.size.height) - (data.acceleration.y * moveFactor)
               let maxX = Double(settingsView.frame.size.width - rect.width)
               let maxY = Double(settingsView.frame.size.height - tabBarHeight!)
               let minY = Double(rect.size.height + statusBarHeight)
               if(moveToX > 0 && moveToX < maxX){
                   rect.origin.x += CGFloat(data.acceleration.x * moveFactor)
               }
               if(moveToY > minY && moveToY < maxY){
                   rect.origin.y -= CGFloat(data.acceleration.y * moveFactor);
               }
               UIView.animate(withDuration: TimeInterval(0),
                              delay: TimeInterval(0),
                              options: UIView.AnimationOptions.curveEaseInOut,
                              animations: {self.lblBattery.frame = rect},
                              completion: nil)
    }
    


}
