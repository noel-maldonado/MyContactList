//
//  DateViewController.swift
//  My Contact List
//
//  Created by Noel Maldonado on 4/15/20.
//  Copyright © 2020 Noel Maldonado. All rights reserved.
//

import UIKit

protocol DateControllerDelegate: class {
    func dateChanged(date: Date)
}

class DateViewController: UIViewController {

    weak var delegate: DateControllerDelegate?
    
   
    @IBOutlet weak var dtpDate: UIDatePicker!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Sets up Save Button and uses SaveDate func
        let saveButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save,
                            target: self,
                            action: #selector(saveDate))
        self.navigationItem.rightBarButtonItem = saveButton
        self.title = "Pick Birthdate"
    }
    
    
    //calls dateChanged in the delegate, passing the chosen date from the date picker
    @objc func saveDate(){
        print("saveDate() called")
        self.delegate?.dateChanged(date: dtpDate.date)
        self.navigationController?.popViewController(animated: true)
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
